---
layout: post
title: "Building a Deterministic AI Agent with Optorch"
description: "Lessons from turning an unstructured document into structured business records using Optorch, an open-source AI orchestration framework, with a node graph, tool calls, and machine-readable LLM output."
date: 2026-06-13
tags: [ai, llm, agents, architecture, engineering]
---

# Building a Deterministic AI Agent with Optorch

Most of the "AI agent" demos you see online are free-form: you give a model some tools and a goal, and you hope it figures out the right sequence of steps. That is great for a demo and terrifying for production. When the same input can produce a different path every run, you cannot debug it, you cannot test it, and you certainly cannot put it in front of a customer.

I recently built an agent that takes a long, messy document and turns it into a set of structured business records, with a few external systems involved along the way. The interesting part was not the model. It was making the AI behave like a normal, predictable piece of software. The tool that made that possible was [Optorch](https://github.com/optorchai/optorch), an open-source AI orchestration framework authored by Chris Churchill.

Here are the lessons that transferred beyond this one project.

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

## Closing thoughts

The thing I will carry forward is this: the hard part of production AI is not the model, it is the engineering around it. Determinism, isolation, contracts, graceful failure, and boring CI are what turn an impressive demo into something you can hand to a colleague and walk away from.

If you want to explore the framework, [Optorch is open source](https://github.com/optorchai/optorch). It is a clean way to think about AI workflows as plain Python nodes and tools rather than magic.

---

*Have you taken an AI prototype to production? I would love to compare notes. Reach out on [LinkedIn](https://linkedin.com/in/dennisheraldi)!*
