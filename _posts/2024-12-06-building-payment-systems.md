---
layout: post
title: 'Lessons from Building Payment Systems at Scale'
description: 'Lessons from building a payment engine that processed around IDR 4 billion a month: idempotency, reconciliation, and multi-provider integrations.'
date: 2024-12-06
tags: [backend, payments, architecture]
---

Building payment systems is one of the most challenging yet rewarding parts of software engineering. Over the past year at Paper.id, I built and maintained a payment engine handling around **IDR 4 billion monthly** across multiple payment methods.

Here are some key lessons I learned along the way.

## 1. Idempotency is Non-Negotiable

In payment systems, the worst thing that can happen is processing a transaction twice. Imagine charging a customer twice for the same order. That's a nightmare scenario.

```go
// Always use idempotency keys
type PaymentRequest struct {
    IdempotencyKey string `json:"idempotency_key"`
    Amount         int64  `json:"amount"`
    Currency       string `json:"currency"`
}

func ProcessPayment(req PaymentRequest) (*PaymentResponse, error) {
    // Check if we've seen this request before
    existing, err := cache.Get(req.IdempotencyKey)
    if err == nil && existing != nil {
        return existing, nil // Return cached response
    }

    // Process the payment...
    result := processNewPayment(req)

    // Cache the result
    cache.Set(req.IdempotencyKey, result, 24*time.Hour)
    return result, nil
}
```

## 2. Design for Failure from Day One

Networks fail. Third-party APIs go down. Databases become unavailable. Your system should handle all of these gracefully.

Key patterns we implemented:

- **Circuit breakers** for external API calls
- **Automatic retries** with exponential backoff
- **Dead letter queues** for failed messages
- **Comprehensive end-to-end recovery mechanisms**

## 3. Reconciliation is Critical

Every transaction needs to be reconcilable. This means:

- Logging every state change
- Storing raw responses from payment providers
- Having automated reconciliation jobs that run daily
- Building tools for manual reconciliation when needed

We implemented **RabbitMQ scheduling** for automated transaction reconciliation, which enabled instant execution of reconciliation report generation. That was a massive improvement over the manual processes we had before.

## 4. Abstract Away Provider Differences

When integrating multiple payment providers, you'll quickly realize each has its quirks:

- Different API formats
- Different webhook structures
- Different error codes
- Different settlement timelines

The solution? Build a **unified payment engine** that abstracts these differences:

```go
type PaymentProvider interface {
    CreatePayment(ctx context.Context, req PaymentRequest) (*PaymentResponse, error)
    GetStatus(ctx context.Context, paymentID string) (PaymentStatus, error)
    ProcessWebhook(ctx context.Context, payload []byte) (*WebhookEvent, error)
}
```

This abstraction allowed us to add new providers without changing our core business logic.

## 5. Monitoring and Observability

You can't fix what you can't see. We invested heavily in observability:

- **OpenTelemetry** for distributed tracing
- Real-time dashboards for transaction success rates
- Alerting on anomalies (sudden drops in success rate, spike in errors)

## Results

These patterns helped us achieve:

- **99% transaction success rate** across all payment methods
- Support for QRIS, bank transfers, virtual accounts, and cross-border remittances
- Adherence to **Bank Indonesia's QRIS scheme requirements**
- **20% improvement in query performance** through table partitioning

## Conclusion

Building payment systems requires thinking about edge cases that rarely occur but have serious consequences when they do. The investment in proper design pays off the first time a provider goes down or a request arrives twice and the system handles it without drama.
