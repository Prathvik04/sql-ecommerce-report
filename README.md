# 04 · SQL E-commerce Report 

35+ queries covering **top products, customer spend, NULL handling, JOINs and DDL constraints** on a 7-table e-commerce database.

## Files (run in order)
| File | Purpose |
|---|---|
| `01_schema.sql` | DDL: 7 tables, PK/FK/UNIQUE/NOT NULL/CHECK/DEFAULT, indexes, 1 view |
| `02_data.sql` | Seed data: 25 customers, 15 products, 70 orders, 107 order lines, 54 payments, 43 reviews |
| `03_queries.sql` | **47 queries** (Q1–Q47) in 6 sections |
| `04_constraint_tests.sql` | 14 statements that must FAIL, proving each constraint works |
| `results.md` | Every query with its actual output |
| `run.py` | Test runner (`python3 run.py`) - executes everything on in-memory SQLite |

## Run it
`python3 run.py`, or in the SQLite shell: `.read 01_schema.sql` → `.read 02_data.sql` → `.read 03_queries.sql`.

## Coverage map
- **Top products:** Q6–Q12, Q39, Q42
- **Customer spend:** Q13–Q20, Q40
- **NULL handling:** Q21–Q30 (IS NULL, COALESCE, NULLIF, COUNT(*) vs COUNT(col), AVG, NOT IN trap, NULL sorting)
- **JOINs:** Q31–Q39 (INNER, LEFT, anti-join, SELF, CROSS, FULL-OUTER emulation, multi-table)
- **DDL constraints:** `01_schema.sql` + `04_constraint_tests.sql`
- **Advanced:** CTEs, window functions (ROW_NUMBER, RANK, NTILE, LAG, running SUM), views, EXPLAIN

## Business rules
Revenue excludes `cancelled` and `returned` orders. Line total = `qty × unit_price × (1 − discount%)`, with NULL discount treated as 0.

## Intentional data quirks (for NULL practice)
NULL phone/city, NULL `shipped_date` for pending/cancelled orders, NULL coupon, NULL rating/review text, a product with NULL category and NULL cost, an empty category (Garden), a discontinued never-sold product.

## Porting to other databases
| SQLite | MySQL | PostgreSQL |
|---|---|---|
| `strftime('%Y-%m', d)` | `DATE_FORMAT(d,'%Y-%m')` | `TO_CHAR(d,'YYYY-MM')` |
| `julianday(a)-julianday(b)` | `DATEDIFF(a,b)` | `a::date - b::date` |
| `INTEGER PRIMARY KEY` | `INT AUTO_INCREMENT PRIMARY KEY` | `SERIAL` / `GENERATED ... AS IDENTITY` |
| `TEXT` dates | `DATE` | `DATE` |
| `SUM(status='cancelled')` | same | `SUM((status='cancelled')::int)` |
