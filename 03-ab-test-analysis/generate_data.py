"""Generate synthetic A/B test data for the sql-portfolio flagship project.

Creates experiment.db (SQLite) with one table:

    users(user_id, group_name, converted, segment)

Design (all synthetic, seeded for reproducibility):
- 40,000 users, assigned ~50/50 to control / treatment.
- Baseline conversion 5.0% in control; treatment converts at 5.8%,
  i.e. an injected lift of +0.8 percentage points.
- segment is an acquisition channel (organic / paid / referral),
  assigned independently of group, used for the breakdown in analysis.sql.

Run:  python3 generate_data.py
Then:  sqlite3 experiment.db < analysis.sql
"""

import os
import random
import sqlite3

SEED = 42
N_USERS = 40000
P_CONTROL = 0.05
P_TREATMENT = 0.058
SEGMENTS = ["organic", "paid", "referral"]
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "experiment.db")


def main():
    rng = random.Random(SEED)
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute(
        "CREATE TABLE users "
        "(user_id INTEGER PRIMARY KEY, group_name TEXT, converted INTEGER, segment TEXT)"
    )
    rows = []
    for user_id in range(1, N_USERS + 1):
        group = "treatment" if rng.random() < 0.5 else "control"
        p = P_TREATMENT if group == "treatment" else P_CONTROL
        converted = 1 if rng.random() < p else 0
        segment = SEGMENTS[rng.randrange(len(SEGMENTS))]
        rows.append((user_id, group, converted, segment))
    cur.executemany("INSERT INTO users VALUES (?, ?, ?, ?)", rows)
    con.commit()
    n_c = sum(1 for r in rows if r[1] == "control")
    n_t = sum(1 for r in rows if r[1] == "treatment")
    print(f"wrote {len(rows)} users to {DB_PATH} (control={n_c}, treatment={n_t})")
    con.close()


if __name__ == "__main__":
    main()
