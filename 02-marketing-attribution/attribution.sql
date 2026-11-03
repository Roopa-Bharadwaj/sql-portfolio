-- Business question: which channel gets credit for conversions?
-- Compares first-touch (all credit to the first interaction) with
-- last-touch (all credit to the last). Both are single-touch rules:
-- they ignore every middle touch, and neither is causal — the same
-- critique that motivates holdouts and incrementality testing.
-- Sample data is inline so this file runs anywhere (SQLite):
--   sqlite3 :memory: < attribution.sql
WITH touches(user_id, channel, ts) AS (
  VALUES (1, 'paid_search', '2026-01-02'),
         (1, 'email',       '2026-01-05'),
         (1, 'social',      '2026-01-09'),
         (2, 'social',      '2026-01-03'),
         (2, 'paid_search', '2026-01-08'),
         (3, 'email',       '2026-01-04'),
         (3, 'email',       '2026-01-07')
),
first_touch AS (
  SELECT user_id, channel AS first_channel
  FROM touches
  WHERE (user_id, ts) IN (SELECT user_id, MIN(ts) FROM touches GROUP BY user_id)
),
last_touch AS (
  SELECT user_id, channel AS last_channel
  FROM touches
  WHERE (user_id, ts) IN (SELECT user_id, MAX(ts) FROM touches GROUP BY user_id)
)
SELECT 'first_touch' AS model, first_channel AS channel, COUNT(*) AS users_credited
FROM first_touch GROUP BY first_channel
UNION ALL
SELECT 'last_touch', last_channel, COUNT(*)
FROM last_touch GROUP BY last_channel
ORDER BY model, channel;
