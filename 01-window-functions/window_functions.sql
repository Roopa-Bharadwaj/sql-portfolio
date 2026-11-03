-- Business question: for each customer, what was their latest order,
-- and how long had it been since their previous order?
-- Techniques: ROW_NUMBER() and LAG() partitioned by customer.
-- Sample data is inline so this file runs anywhere (SQLite):
--   sqlite3 :memory: < window_functions.sql
WITH orders(customer, order_date, amount) AS (
  VALUES ('Asha', '2026-01-05', 40),
         ('Asha', '2026-01-20', 60),
         ('Asha', '2026-03-02', 25),
         ('Ben',  '2026-02-10', 80),
         ('Ben',  '2026-02-11', 15)
),
ranked AS (
  SELECT customer, order_date, amount,
         ROW_NUMBER() OVER (PARTITION BY customer ORDER BY order_date DESC) AS rn,
         LAG(amount) OVER (PARTITION BY customer ORDER BY order_date) AS prev_amount,
         LAG(order_date) OVER (PARTITION BY customer ORDER BY order_date) AS prev_date
  FROM orders
)
-- Latest order per customer (window results can't be filtered in WHERE,
-- so the ranking is wrapped in a subquery and filtered outside).
SELECT customer, order_date AS latest_order, amount,
       prev_amount,
       CAST(julianday(order_date) - julianday(prev_date) AS INTEGER) AS days_since_prev
FROM ranked
WHERE rn = 1
ORDER BY customer;
