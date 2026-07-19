---
layout: post
title: "Making Retries Safe in Multi-Step Workflows"
description: "Lessons from adding idempotency, partial-failure recovery, and controlled manual intervention to a stateful workflow orchestrator."
date: 2026-07-19
tags: [backend, reliability, idempotency, distributed-systems]
---

A retry is not the same as recovery.

In a simple request, trying again may be enough. In a stateful workflow, the first attempt may already have created a plan, completed several steps, or changed another system before the failure appeared. Starting over can duplicate work. Continuing blindly can skip work. Marking everything complete can hide an unfinished operation.

The system I have in mind is a workflow orchestrator. It takes a request, works out the order to run a set of dependent steps (a plan, essentially a directed graph of nodes), then executes that plan one node at a time, calling other services to do the real work and waiting for their status back. If you have ever built something that turns an order or request into a sequence of coordinated steps across other systems, the shape will be familiar.

I recently worked on recovery for exactly this kind of service. The difficult part was not adding a retry loop. It was making each retry understand what had already happened.

Three failure cases shaped the design:

1. A plan was created, but the workflow failed before it recorded the result.
2. A downstream operation completed only part of its work before failing.
3. The work completed, but its status notification never reached the orchestrator.

Each case needed a different recovery path.

## Reuse the operation, not just the request

The first problem appeared near the start of the workflow. A retry could enter plan creation again after the plan had already been stored.

The fix was to look up the plan by a stable business key before creating anything:

```text
plan = repository.findByBusinessKey(key)

if plan does not exist:
    plan = repository.create(key, newCorrelationId())

return plan
```

The important part is that the key represents the business operation, not one HTTP request or one workflow attempt. Request IDs change. Retry counters change. The identity of the work should not.

The same rule applies when calling another service. The orchestrator stores one correlation ID with the plan and reuses it on every attempt. If a retry generates a new ID, the downstream service sees new work and cannot recognize what it has already processed.

A lookup is enough when the workflow guarantees one active start at a time. If concurrent starts are possible, the database also needs a uniqueness rule. Otherwise two workers can both observe "not found" and create duplicate rows.

## Save progress before crossing a service boundary

Before a node calls another service, the orchestrator records that the node has started. It only marks the node complete after the downstream call succeeds and the returned data has been attached to the plan.

This ordering matters:

```text
record node as running
call downstream service with stable correlation ID
store returned data
mark node complete
```

If the call fails, the node remains visibly incomplete. The next attempt has a durable point from which to recover.

Doing this in the opposite order creates ambiguity. A node marked complete before its side effects finish looks successful to every later process. A side effect performed before any state is recorded leaves no evidence that the first attempt happened.

There is still no single database transaction across two services. The goal is not impossible atomicity. The goal is to leave enough durable evidence for both sides to make the next attempt safe.

## Partial failure belongs to the service that owns the work

The downstream operation could expand one input into several new entities. A failure after creating the first few entities made a full restart dangerous: the successful subset would be created again.

The downstream service therefore tracks progress under the correlation ID. On retry, it distinguishes between:

- entities already processed successfully;
- entities that still need processing;
- entities that exhausted their own retry policy.

The retry skips the completed subset and continues with the missing work. This is more reliable than asking the orchestrator to reconstruct another service's internal progress.

The ownership rule is useful beyond this project:

> The component that performs a side effect should also own the idempotency check for that side effect.

An orchestrator can supply a stable key, but it usually cannot know whether a remote write completed before a timeout.

This does not make the whole pipeline idempotent by itself. The orchestrator must also incorporate the returned nodes and links safely. If those local writes use new IDs on every attempt and are persisted one at a time, a crash halfway through can still duplicate part of the graph on replay. Idempotency has to cover both the remote side effect and the local materialization of its result.

## Status and graph traversal are separate decisions

One subtle bug appeared when a completed parent node had an unfinished child. The planner filtered out the completed parent, which also prevented traversal from reaching its child.

The parent did not need to execute again, but the graph still needed to pass through it.

That led to a useful distinction:

- **Should this node execute?** No, if it is already complete.
- **Should traversal continue through this node?** Yes, if descendants may still need work.

Conflating those questions can make incomplete work disappear behind a successful ancestor. In any graph-based workflow, terminal status should stop execution, not necessarily traversal.

The status itself must also describe reality. A successful downstream response can move a node to complete. A technical failure should leave it retryable. A business validation failure should pause for resolution rather than repeat an operation that will produce the same rejection.

## Use layers of recovery

No single recovery mechanism covered every failure. The final design used several layers.

### 1. Automatic retry for transient failures

Technical failures remain in a recoverable state. The workflow can retry them with the same plan, node identity, and downstream correlation ID.

Recovery attempts outside the normal workflow are bounded by a persisted counter and recovery timestamp, so an operator cannot replay a permanently broken node forever.

### 2. Replay the normal status path

When a status notification is lost, recovery fetches the current entity and sends it through the same status-handling path used during normal processing.

This is safer than maintaining separate "recovery logic" that gradually drifts from production behavior. Recovery should reuse normal code wherever possible.

### 3. Pause business failures

Business errors are different from network errors. Retrying invalid input immediately only creates noise. These failures stay visible until the underlying issue is resolved, after which the workflow can continue.

### 4. Provide a controlled operator escape hatch

Some situations cannot be inferred safely. For example, an external action may have succeeded while every completion signal was lost.

For those cases, the service exposes a manual recovery operation. The normal mode replays the standard status checks. A force mode can complete a specific node when an operator has verified the external result.

That endpoint is deliberately guarded:

- only configured roles may use it;
- the request must identify a valid node or related entity;
- the operator supplies a reason;
- every intervention records the user, reason, time, and whether force was used.

Manual intervention is not a replacement for automation. It is a bounded fallback for cases where automation no longer has enough information to decide.

## Make exhausted recovery visible

Silently abandoning a node after its final retry is worse than failing clearly.

The recovery design stores enough state to identify exhausted nodes and escalate them. However, the version I worked on did not yet run an active watchdog that searched for stuck nodes. Detection still began with monitoring or an operator.

That is an important limit: making a node recoverable is not the same as detecting it automatically.

When an exhausted node is handled, the service:

- records that the node is no longer automatically recoverable;
- adds an activity entry explaining what happened;
- moves the parent operation into a visible failure state;
- keeps the manual path available for investigation.

The operator should not need database access to discover why a workflow stopped. Recovery state is part of the product's operational interface.

## Test failures at the boundaries

Happy-path tests say little about recovery. The useful tests interrupt the workflow between state changes and side effects.

The scenarios that gave the most confidence were:

- starting the same business operation twice reuses one plan;
- retrying after plan creation does not create another plan;
- retrying a partially completed downstream operation skips existing results;
- new results are still processed during that retry;
- a successful downstream response does not run again;
- a technical error remains retryable;
- a business error waits for resolution;
- a missing status notification can be recovered through the normal path;
- an unauthorized user cannot force completion;
- a successful manual recovery produces an audit record;
- a node with no retries left becomes visibly failed.

These tests form a failure matrix rather than a traditional list of endpoints. For each service boundary, ask what happens if the process stops immediately before and immediately after the side effect.

## What I would improve next

The recovery layers make retries safer, but there are still ways to reduce the number of recoveries needed.

An outbox and inbox around status notifications would close more of the gap between state changes and message delivery. A database uniqueness constraint would protect plan creation if concurrent starts become possible. Plan and execution creation should also be atomic, or replay should repair a plan whose execution was never stored.

For forced recovery, the audit intent should be durable before the completion event is emitted. Otherwise a later failure can complete work without preserving the operator record. Fault-injection tests could exercise these boundaries automatically instead of relying on manually induced failures.

Those additions are useful when the observed failure rate or concurrency justifies them. The current design first addressed the failures that had actually happened.

## Closing thoughts

Reliable recovery is not a larger retry count. It is a set of agreements:

- the same work keeps the same identity;
- progress survives process restarts;
- the service performing a side effect can recognize it later;
- statuses reflect what really completed;
- transient and business failures follow different paths;
- manual intervention is authorized, explained, and auditable.

Once those agreements are in place, retries stop being a gamble. They become another normal path through the system.
