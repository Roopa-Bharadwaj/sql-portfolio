# A/B test analysis: should we roll out the treatment? (flagship)

## Business question

A treatment was tested against control on conversion. Should it roll out
to all users — or is the apparent lift noise?

## Design (synthetic data, seeded)

- 40,000 users, assigned ~50/50 to control / treatment.
- Control converts at 5.0%; treatment at 5.8% — an injected lift of
  +0.8 percentage points, so the analysis can be checked against a
  known truth.
- `segment` is an acquisition channel (organic / paid / referral),
  assigned independently of group, for the breakdown.

## Methods

- SRM check: chi-square on the group split (1 degree of freedom; a
  value above 3.84 would flag a randomization problem).
- Two-proportion z-test: lift with a 95% confidence interval.
- Segment breakdown: lift by acquisition channel.
- Decision rule: roll out only if the interval excludes zero. A point
  estimate alone is not a decision.

## Findings

- Control: 19,901 users, 4.81% converted. Treatment: 20,099 users,
  6.00% converted.
- SRM check: chi-square 0.98 — well below 3.84, so the split looks
  properly randomized.
- Lift: +1.19 percentage points, 95% CI (0.74pp, 1.63pp). The interval
  excludes zero, so the lift is distinguishable from noise at the 5%
  level — and it covers the injected +0.8pp truth (estimates differ
  from the truth by chance; that is exactly what the interval is for).
- By segment, the lift is positive in all three channels: organic
  +0.77pp, paid +1.16pp, referral +1.62pp.
- Recommendation: roll out. The effect is positive overall and in
  every segment, with no SRM flag.

## Run it

```bash
python3 generate_data.py        # creates experiment.db
sqlite3 experiment.db < analysis.sql
```

`generate_data.py` uses only the Python standard library. The generated
database is git-ignored: running the generator is the first step, not an
afterthought, so anyone cloning the repo reproduces the same data.
