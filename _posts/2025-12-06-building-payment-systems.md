---
layout: post
title: 'What I Learned Building a Payment Engine'
description: 'Idempotency, reconciliation, and provider abstraction lessons from a payment engine handling around IDR 4 billion a month.'
date: 2025-12-06
tags: [backend, payments, architecture]
---

Most bugs show someone the wrong number on a screen. A payment bug puts someone's money in the wrong place, and you usually hear about it from the customer before your dashboard tells you.

I spent about a year at Paper.id building and maintaining a payment engine that handled around **IDR 4 billion a month** across QRIS, bank transfers, virtual accounts, and cross-border remittance. These are the things I would tell myself at the start.

## 1. Idempotency comes before anything else

The worst outcome is charging a customer twice for one order. Retries, double-clicked buttons, and provider callbacks delivered more than once all push you there.

Every request carries an idempotency key, checked before any work happens:

```go
type PaymentRequest struct {
    IdempotencyKey string `json:"idempotency_key"`
    Amount         int64  `json:"amount"`
    Currency       string `json:"currency"`
}

func ProcessPayment(req PaymentRequest) (*PaymentResponse, error) {
    existing, err := cache.Get(req.IdempotencyKey)
    if err == nil && existing != nil {
        return existing, nil
    }

    result := processNewPayment(req)

    cache.Set(req.IdempotencyKey, result, 24*time.Hour)
    return result, nil
}
```

The cache is a shortcut, and worth naming as one. It catches duplicates that arrive seconds apart, which is most of them, but it is not a durable record. If the guarantee has to survive a restart or outlive the TTL, the key belongs in the database behind a unique constraint.

## 2. Assume every dependency will fail

Providers go down. Callbacks arrive late, twice, or never. The design question is not whether that happens, it is what the system does when it does.

Four things carried most of the weight:

- circuit breakers on provider calls, so one slow provider cannot tie up every worker;
- exponential backoff on retries, so a struggling provider is not retried into the ground;
- dead letter queues, so a message that keeps failing is parked somewhere visible instead of disappearing;
- a recovery path that replays a stuck transaction through the normal flow.

The last one is the easiest to get wrong. A separate "recovery mode" slowly drifts away from the real code until nobody trusts it.

## 3. Reconciliation is what lets you answer questions later

Every transaction has to be explainable after the fact, sometimes weeks later, sometimes to someone outside the company. In practice that meant logging every state change rather than only the final one, and storing the raw provider response instead of our parsed version of it.

Storing raw responses felt wasteful right up until the first time a provider disagreed with us about what they had sent.

Reconciliation ran as a daily job, scheduled through RabbitMQ so a report could also be generated on demand instead of waiting for the next nightly run. A manual tool covered the cases the job could not settle on its own.

## 4. Hide provider differences behind one interface

Every provider has its own quirks: request format, webhook shape, error codes, settlement timing. Once those differences reach business logic, every new provider means touching the core.

One interface kept them out:

```go
type PaymentProvider interface {
    CreatePayment(ctx context.Context, req PaymentRequest) (*PaymentResponse, error)
    GetStatus(ctx context.Context, paymentID string) (PaymentStatus, error)
    ProcessWebhook(ctx context.Context, payload []byte) (*WebhookEvent, error)
}
```

Adding a provider became a new implementation plus its own tests, with nothing else moving.

The part that does not fit neatly is settlement timing. An interface can normalize the shape of a response, not the fact that one provider settles instantly and another settles the next working day. That difference has to be modeled, not hidden.

## 5. Watch success rates, not just errors

Payment failures are rarely loud. A provider does not return 500, it starts declining one card type, or a webhook signature check quietly begins failing for a single integration.

OpenTelemetry traces made one transaction followable across services. The alerts that actually caught problems watched success rate per provider and per payment method rather than total error count. A drop from 99% to 96% on one method disappears in an aggregate and is obvious in a breakdown.

## Where it ended up

The engine settled at a **99% transaction success rate** across QRIS, bank transfers, virtual accounts, and remittance, within Bank Indonesia's QRIS scheme requirements. Partitioning the transaction tables took about **20% off query time** as volume grew.

## Closing thoughts

None of this is clever. It is idempotency keys, backoff, stored raw responses, and one interface per provider. The work is in deciding those things early, because every one of them is painful to retrofit once money is already moving.
