# Window functions: latest order per customer

## Business question

For each customer, what was their latest order — and how long had it been
since their previous order? That gap is the raw material for recency
analysis: who is going quiet, and who just bought.

## Techniques

- `PARTITION BY customer` so each customer's orders rank independently.
- `ROW_NUMBER()` for exactly one row per customer (unlike `RANK()`,
  which shares a rank on ties).
- `LAG()` for the previous order's amount and date.
- Window results can't be filtered in `WHERE`, so the ranking is wrapped
  in a subquery and filtered outside (`rn = 1`).
- `julianday()` for date math in SQLite (SQLite has no `datediff`).

## Findings (sample data)

- Asha's latest order: 2026-03-02, $25 — 41 days after her previous order.
- Ben's latest order: 2026-02-11, $15 — 1 day after his previous order.

## Run it

```bash
sqlite3 :memory: < window_functions.sql
```
