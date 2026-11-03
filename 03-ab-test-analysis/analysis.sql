-- Flagship A/B analysis: did the treatment lift conversion?
-- Run against experiment.db (created by generate_data.py).
-- Business question: should we roll out the treatment to all users?
-- Methods: SRM check (chi-square, 1 df), two-proportion z-test,
-- 95% confidence interval for the lift, and a segment breakdown.
-- Read the CI, not just the point estimate: if it excludes zero,
-- the lift is distinguishable from zero at the 5% level.

-- 1. Sample sizes and conversions by group
SELECT group_name,
       COUNT(*) AS users,
       SUM(converted) AS conversions,
       ROUND(100.0 * SUM(converted) / COUNT(*), 2) AS conversion_pct
FROM users
GROUP BY group_name;

-- 2. SRM check: is the split plausibly 50/50?
-- chi-square = SUM((observed - expected)^2 / expected); with 1 degree of
-- freedom, a value above 3.84 would flag a randomization problem.
SELECT ROUND(
    SUM((cnt - total / 2.0) * (cnt - total / 2.0) / (total / 2.0)), 3) AS chi_square_srm
FROM (SELECT COUNT(*) AS cnt FROM users GROUP BY group_name),
     (SELECT COUNT(*) AS total FROM users);

-- 3. Lift with 95% confidence interval (two-proportion z, normal approx.)
WITH agg AS (
  SELECT group_name,
         COUNT(*) AS n,
         SUM(converted) AS x,
         1.0 * SUM(converted) / COUNT(*) AS p
  FROM users
  GROUP BY group_name
),
c AS (SELECT n, x, p FROM agg WHERE group_name = 'control'),
t AS (SELECT n, x, p FROM agg WHERE group_name = 'treatment')
SELECT ROUND(100.0 * (t.p - c.p), 2) AS lift_pp,
       ROUND(100.0 * SQRT(t.p * (1 - t.p) / t.n + c.p * (1 - c.p) / c.n), 2) AS se_pp,
       ROUND(100.0 * ((t.p - c.p) - 1.96 * SQRT(t.p * (1 - t.p) / t.n + c.p * (1 - c.p) / c.n)), 2) AS ci_low_pp,
       ROUND(100.0 * ((t.p - c.p) + 1.96 * SQRT(t.p * (1 - t.p) / t.n + c.p * (1 - c.p) / c.n)), 2) AS ci_high_pp
FROM c, t;

-- 4. Segment breakdown: conversion and lift by acquisition channel
WITH agg AS (
  SELECT segment, group_name,
         COUNT(*) AS n,
         1.0 * SUM(converted) / COUNT(*) AS p
  FROM users
  GROUP BY segment, group_name
)
SELECT c.segment,
       ROUND(100.0 * c.p, 2) AS control_pct,
       ROUND(100.0 * t.p, 2) AS treatment_pct,
       ROUND(100.0 * (t.p - c.p), 2) AS lift_pp
FROM agg c
JOIN agg t ON t.segment = c.segment AND t.group_name = 'treatment'
WHERE c.group_name = 'control'
ORDER BY c.segment;
