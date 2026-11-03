# Marketing attribution: first-touch vs. last-touch

## Business question

Which channel gets credit for a conversion — the first interaction or the
last? The answer changes where budget goes, so the rule behind the answer
matters as much as the numbers.

## Techniques

- First-touch: the channel at each user's `MIN()` timestamp.
- Last-touch: the channel at each user's `MAX()` timestamp.
- One row per user per model, then counts by channel.

## Findings (sample data)

- First-touch credits: email 1, paid_search 1, social 1.
- Last-touch credits: email 1, paid_search 1, social 1.
- The totals tie here, but the users behind them differ: user 1 moves
  from paid_search (first) to social (last), and user 2 from social
  (first) to paid_search (last). Same totals, different story.

## Limitation (stated plainly)

Both rules are single-touch: they ignore every middle touch, and neither
is causal. A channel that appears early or late is not thereby proven to
have caused the conversion — that is what holdouts and incrementality
testing are for.

## Run it

```bash
sqlite3 :memory: < attribution.sql
```
