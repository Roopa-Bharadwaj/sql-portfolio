# sql-portfolio

SQL projects framed as business questions, each ending in a recommendation.
Built while brushing up SQL for senior data science and marketing analytics
roles — the emphasis is measurement, experimentation, and attribution, not
isolated query exercises.

## Projects

| Folder | Project | Status |
| ------ | ------- | ------ |
| `01-window-functions` | Each customer's latest order, and time since their previous order | Complete (sample data) |
| `02-marketing-attribution` | First-touch vs. last-touch credit | Complete (sample data) |
| `03-ab-test-analysis` | Should we roll out the treatment? (flagship) | Complete (synthetic data, runnable) |
| `04-twitch-gaming` | Gaming data analysis | To come (Codecademy §9 project) |
| `05-public-dataset` | A project on a public dataset | To come |

## Running the flagship

```bash
cd 03-ab-test-analysis
python3 generate_data.py        # creates experiment.db (40,000 synthetic users)
sqlite3 experiment.db < analysis.sql
```

## Data honesty

All data here is synthetic or public. No work data, no proprietary numbers,
no internal projects. Sample datasets are inline in the SQL files so each
analysis runs anywhere SQLite runs.

Contact: roopa.bharadwaj0511@gmail.com
