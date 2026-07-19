---
layout: post
title: "Building a Deterministic AI Agent with Optorch"
description: "Lessons from turning an unstructured document into structured business records using Optorch, an open-source AI orchestration framework, with a node graph, tool calls, and machine-readable LLM output."
date: 2026-06-13
tags: [ai, llm, agents, architecture, engineering]
---

Most of the "AI agent" demos you see online are free-form: you give a model some tools and a goal, and you hope it figures out the right sequence of steps. That is great for a demo and terrifying for production. When the same input can produce a different path every run, you cannot debug it, you cannot test it, and you certainly cannot put it in front of a customer.

I recently built an agent that takes a long, messy document and turns it into a set of structured business records, with a few external systems involved along the way. The interesting part was not the model. It was making the AI behave like a normal, predictable piece of software. The tool that made that possible was [Optorch](https://github.com/optorchai/optorch), an open-source AI orchestration framework authored by Chris Churchill.

Here are the lessons that transferred beyond this one project.

## The shape of the pipeline

The mental model is simple: a document goes in, the orchestrator runs a fixed sequence of small nodes, and structured records come out. Each node does one job with its own prompt and tools, and the order is configuration rather than something the model decides.

<svg role="img" aria-label="A vertical pipeline: a document enters, passes through five ordered nodes (extract, enrich, reconcile and validate, persist records, create output), and produces a structured result." viewBox="0 0 720 580" style="width:100%;max-width:520px;height:auto;display:block;margin:2rem auto;font-family:'DM Sans',system-ui,sans-serif;">
  <defs>
    <marker id="arrowhead" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="currentColor" fill-opacity="0.5"/>
    </marker>
  </defs>

  <!-- grouping bracket -->
  <path d="M162,66 H150 V492 H162" fill="none" stroke="currentColor" stroke-opacity="0.3" stroke-width="1.5"/>
  <text transform="translate(132,279) rotate(-90)" text-anchor="middle" font-size="12" fill="currentColor" fill-opacity="0.55">deterministic node graph</text>

  <!-- input -->
  <rect x="285" y="10" width="150" height="36" rx="18" fill="currentColor" fill-opacity="0.06" stroke="currentColor" stroke-opacity="0.35"/>
  <text x="360" y="33" text-anchor="middle" font-size="14" font-weight="600" fill="currentColor">Document in</text>

  <!-- arrows + nodes -->
  <line x1="360" y1="46" x2="360" y2="66" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <rect x="234" y="66" width="252" height="58" rx="10" fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.35"/>
  <circle cx="234" cy="95" r="15" fill="#2563eb"/>
  <text x="234" y="99" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">1</text>
  <text x="362" y="91" text-anchor="middle" font-size="15" font-weight="600" fill="currentColor">Extract</text>
  <text x="362" y="109" text-anchor="middle" font-size="12" fill="currentColor" fill-opacity="0.6">LLM call, returns JSON</text>

  <line x1="360" y1="124" x2="360" y2="158" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <rect x="234" y="158" width="252" height="58" rx="10" fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.35"/>
  <circle cx="234" cy="187" r="15" fill="#2563eb"/>
  <text x="234" y="191" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">2</text>
  <text x="362" y="183" text-anchor="middle" font-size="15" font-weight="600" fill="currentColor">Enrich</text>
  <text x="362" y="201" text-anchor="middle" font-size="12" fill="currentColor" fill-opacity="0.6">external async AI</text>
  <text x="500" y="192" text-anchor="start" font-size="12" fill="currentColor" fill-opacity="0.55">poll · timeout · fallback</text>

  <line x1="360" y1="216" x2="360" y2="250" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <rect x="234" y="250" width="252" height="58" rx="10" fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.35"/>
  <circle cx="234" cy="279" r="15" fill="#2563eb"/>
  <text x="234" y="283" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">3</text>
  <text x="362" y="284" text-anchor="middle" font-size="15" font-weight="600" fill="currentColor">Reconcile &amp; validate</text>

  <line x1="360" y1="308" x2="360" y2="342" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <rect x="234" y="342" width="252" height="58" rx="10" fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.35"/>
  <circle cx="234" cy="371" r="15" fill="#2563eb"/>
  <text x="234" y="375" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">4</text>
  <text x="362" y="376" text-anchor="middle" font-size="15" font-weight="600" fill="currentColor">Persist records</text>

  <line x1="360" y1="400" x2="360" y2="434" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <rect x="234" y="434" width="252" height="58" rx="10" fill="currentColor" fill-opacity="0.03" stroke="currentColor" stroke-opacity="0.35"/>
  <circle cx="234" cy="463" r="15" fill="#2563eb"/>
  <text x="234" y="467" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">5</text>
  <text x="362" y="459" text-anchor="middle" font-size="15" font-weight="600" fill="currentColor">Create output</text>
  <text x="362" y="477" text-anchor="middle" font-size="12" fill="currentColor" fill-opacity="0.6">call another service</text>
  <text x="500" y="468" text-anchor="start" font-size="12" fill="currentColor" fill-opacity="0.55">via MCP</text>

  <line x1="360" y1="492" x2="360" y2="524" stroke="currentColor" stroke-opacity="0.5" stroke-width="2" marker-end="url(#arrowhead)"/>

  <!-- output -->
  <rect x="265" y="524" width="190" height="36" rx="18" fill="currentColor" fill-opacity="0.06" stroke="currentColor" stroke-opacity="0.35"/>
  <text x="360" y="547" text-anchor="middle" font-size="14" font-weight="600" fill="currentColor">Structured result</text>
</svg>

_Each node is a plain Python class with a prompt and a set of tools. The orchestrator runs them in a fixed order, so the flow is reviewable and testable even though the work inside each node is done by a model._

## 1. Make the flow deterministic, not the model

Optorch models a workflow as a **node graph**. Each node is a small unit of work declared in configuration: which model it uses, which tools it can call, what its prompt is, and where to go next. The orchestrator runs a node, looks at its routing, and moves to the next one. The order of steps lives in config, not in the model's head.

```yaml
extract_document:
  class: StepNode
  llm: default
  tools: [extract_document]
  prompts:
    system: nodes/extract_document
  routing:
    type: dynamic
    default: validate_records   # the next node in the chain
```

This one decision changed everything. The model still does the hard, fuzzy work inside each node, but the shape of the pipeline is fixed and reviewable. When something breaks, the stack trace points at a specific node, not at "the agent." I can reason about step 4 without thinking about steps 1 through 3.

## 2. One job per node, with an isolated context

The temptation with chat models is to let the whole conversation accumulate and pass it along. That is how you get context bleed: step 5 reads step 2's chatter, the suggestions engine's noise, and three tool results it does not need, then confidently does the wrong thing.

I gave each node its own tightly scoped context. A step sees only the system prompt for that step plus the exact input it needs, read from a shared run store rather than from the chat history. Each model call stays focused, the prompts stay short, and the token bill drops. A node is a function with a narrow signature, and I treated it like one.

## 3. Treat the model's output as a contract

A chat model will happily return prose. For a pipeline you want data. The trick is to make the output a contract: ask for a JSON block with an exact schema, then parse and validate it. Suddenly your language model behaves like a structured-data API.

```json
{ "customer": "...", "items": [ { "id": "...", "value": 0 } ] }
```

The prompt spells out that schema and tells the model to return it and nothing else. Tools reinforce this. In Optorch you register a plain function with a decorator, and its type hints plus docstring become the schema the model sees. The prompt and the tool stay in sync, because they are generated from the same place.

```python
from optorch.tools.decorators import tool

@tool
async def extract_document(payload: dict) -> dict:
    """Persist the records extracted from the document.

    Args:
        payload: the structured object the model produced.
    """
    ...
```

The system prompt names the tool explicitly ("call `extract_document(payload=...)`"), the model emits a tool call, and the framework runs it. That is the whole loop, and it is the part worth reusing in any service.

## 4. External AI is asynchronous, so design for waiting

One of my steps called a partner's AI service that does not answer immediately. It accepts the work, returns "pending," and settles minutes later. If you treat that like a normal request you either block forever or give up too early.

The pattern that worked:

- Submit, then **wait** a sensible amount before the first poll. Polling immediately just wastes calls.
- **Poll on an interval** until every item reaches a terminal state or a timeout fires.
- Emit a **heartbeat** to the UI between polls so a long wait does not look like a hung process.
- Treat **"still pending at timeout"** as a real outcome, not an error. Hand those items to a different path.

```python
await asyncio.sleep(INITIAL_WAIT)
deadline = time.time() + POLL_TIMEOUT
while not all_settled() and time.time() < deadline:
    await poll_once()
    await asyncio.sleep(POLL_INTERVAL)
```

None of this is glamorous, but it is the difference between a demo and something an operator can trust.

## 5. Always keep a non-AI fallback

The most reliable AI feature I shipped was the part that runs when the AI is unavailable. When the vendor agent failed, the step fell back to a simpler deterministic extraction so the pipeline still produced a usable result. When an external write was rejected for a permission reason that no payload could fix, the step surfaced an honest "skipped" status instead of faking success.

Graceful degradation is a feature. A pipeline that produces a smaller correct answer beats one that produces a confident wrong one.

## 6. Bridge other runtimes with MCP

Part of the system was a separate service written in a different language. Rather than reimplement it, I exposed it over the **Model Context Protocol (MCP)** and let the agent call its tools the same way it calls local ones. MCP turns "another team's service" into "just another set of tools," which kept the integration boundary clean and language-agnostic.

## 7. Stay provider-agnostic, and ship it like everything else

Two smaller decisions saved a lot of pain:

- **Point every model client at an OpenAI-compatible proxy.** The underlying provider can change without touching code, because the service only knows about a base URL, a key, and a model name. Swapping models becomes a config change.
- **Make the service build like the rest of the stack.** It was mainly Python, but I wrapped it so it builds and produces a container image the same way our other services do. The lesson: do not invent a snowflake pipeline for your AI service. The moment it builds and deploys like everything else, it stops being a special case and starts being maintainable.

## 8. Tame the randomness at the model layer, too

Everything above makes the *pipeline* deterministic. The *model* inside each node is still stochastic: the same prompt can produce a different answer because an LLM samples the next token from a probability distribution. George Karapetyan's [guide to taming randomness in LLM agents](https://medium.com/@georgekar91/making-ai-agent-responses-more-repeatable-a-guide-to-taming-randomness-in-llm-agents-fc83d3f247be) is a good tour of the knobs; here is how they landed on this project.

- **Turn the temperature to zero on any step whose output you parse.** The node that emits the structured JSON runs at `temperature=0`, so it does a greedy decode and takes the most likely token every time. It is the cheapest consistency win there is. One caveat worth knowing: even at zero you are not promised bit-for-bit identical output, because floating-point quirks and model-version changes still leak a little randomness in.
- **Constrain the output until there is little left to vary.** A strict JSON schema, exact enumerated values, and "set only the fields you were asked to" turn an open-ended generation into something closer to filling in a form. Less room to improvise means less variance. The article calls this reducing the model's degrees of freedom, and that matched my experience exactly.
- **If it has to be right every time, take it away from the model.** This was my biggest lesson, and it is the one not in the article. A single value needed to be exact, and the model kept getting it subtly wrong, partly because it could not even *see* the field it was meant to set. The fix was not a cleverer prompt; it was moving that decision into deterministic code that derives the value from structured input. Prompt the fuzzy stuff; encode the stuff that must be correct.
- **Cache and dedupe identical work.** The final tool collapses concurrent identical calls into one, so the same input cannot fan out into two divergent runs. When you cannot make a call perfectly reproducible, the next best thing is to make it only once.
- **Make drift observable.** Each run emits a trace of what the agent did and which APIs it called. Determinism you cannot see is determinism you cannot trust: when a model, or a model *version*, starts behaving differently, you want to catch it in a diff rather than from a customer.

What I would still add: a fixed `seed` on the providers that support it, and a small golden-set regression (same document in, assert the same shape out) so a model upgrade that quietly changes behavior shows up in CI instead of in production.

## Closing thoughts

The thing I will carry forward is this: the hard part of production AI is not the model, it is the engineering around it. Determinism, isolation, contracts, graceful failure, and boring CI are what turn an impressive demo into something you can hand to a colleague and walk away from.

If you want to explore the framework, [Optorch is open source](https://github.com/optorchai/optorch). It is a clean way to think about AI workflows as plain Python nodes and tools rather than magic.
