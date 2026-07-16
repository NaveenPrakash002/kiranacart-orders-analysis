# KiranaCart — Orders & Customer Analysis

SQL analysis of a ~12,000-order e-commerce dataset in PostgreSQL. Four business questions, four findings — including a real AOV bug traced to how SQL handles NULLs.

## Findings

**1. Revenue is concentrated in a small customer base.**
The top 10 customers account for 16.0% of delivered revenue; the top ~1% (20 customers) account for 27.3%. It's a metro-heavy list — Mumbai, Bengaluru, Hyderabad, Chennai lead. A retention or loyalty push aimed at this cohort protects a disproportionate share of revenue.

**2. Electronics wins on price, Grocery wins on volume.**
Electronics leads category revenue at 27.7%, Grocery is second at 17.8%. Together they're nearly half of all revenue, while Books and Toys trail under 5% each — a budget spread evenly across all 8 categories would be missing where the money actually is.

**3. Repeat rate is 36.5% — but the real story is the other 63.5%.**
1,371 customers actually placed an order; 500 of them ordered more than once. That's a decent repeat rate for a marketplace, but the one-and-done majority is the bigger lever — most customers try once and don't come back. (Also worth flagging: the denominator here is customers who ordered, not all 2,000 registered accounts — a common place this metric gets misreported.)

**4. The dashboard's AOV number was wrong — and I found out why.**
The naive `AVG(order_total)` gives Rs 1,450.51. The correct number, `SUM(order_total) / COUNT(*)`, gives Rs 1,421.53 — a Rs 28.98 gap. The cause: 187 delivered orders are free/promo orders with `order_total = NULL`. `AVG()` silently drops NULLs from both the total and the count, so those orders disappear from the calculation entirely. `COUNT(*)` doesn't drop them — it keeps them in the denominator, correctly counting them as Rs 0 orders. A free order still used real inventory and fulfillment capacity, so excluding it overstates performance. This is the kind of bug that looks fine on a dashboard until someone checks the math.

**5. Order volume spikes in Oct–Nov; basket size doesn't.**
Festive-season months run at ~1.7x normal order volume, but AOV stays roughly flat across the year. The seasonal lift is about more people ordering, not people spending more per order.


## Files

- `schema_and_seed.sql` — table definitions + seed data
- `queries.sql` — the queries behind each finding above
- `KiranaCart_Orders_Analysis.pdf` — full write-up with result tables

Data is synthetic, built to model a mid-market e-commerce marketplace. Not a real company's numbers.
