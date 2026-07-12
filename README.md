# 📊 Target Brazil E-Commerce Data Analysis (SQL)

## 📝 Overview
This project is an exploratory SQL analysis of a target e-commerce dataset, performed entirely in **Google BigQuery**. The goal was to practice writing real-world analytical SQL queries and extract business insights around customer behavior, order trends, delivery performance, and payments — the kind of questions a data analyst would be asked to answer for an e-commerce business. 

The dataset models a typical e-commerce backend with separate tables for customers, orders, order line items, payments, and geolocation, requiring joins across multiple tables to answer most business questions.

---

## 🗄️ Dataset & Architecture
* **Source table root:** `target-500311.Target_Sql`
* **Tables used:**
  * `customers` – customer IDs, unique IDs, zip code, city, state
  * `orders` – order IDs, purchase timestamp, delivery dates
  * `orders_items` – order line items, freight value
  * `payments` – payment type and installment details
  * `geolocation` – zip code to lat/long mapping

---

## 🛠️ Tools Used

| Tool | Purpose |
| :--- | :--- |
| **Google BigQuery** | Cloud data warehouse used to store and query the dataset |
| **BigQuery SQL Editor** | Writing, running, and validating all SQL queries |
| **Standard SQL** | Query language used throughout the project |

---

## 🧮 SQL Techniques Demonstrated
* **Basic retrieval:** `SELECT`, `LIMIT` for initial data exploration.
* **Aggregate functions:** `COUNT()`, `COUNT(DISTINCT ...)`, `MIN()`, `MAX()`, `AVG()`.
* **Grouping and sorting:** `GROUP BY`, `ORDER BY` (ascending/descending) for ranked and summarized results.
* **Filtering:** `WHERE` clauses combined with date/year extraction to scope results to specific periods.
* **Date and time functions:**
  * `EXTRACT()` – pulling out year, month, hour, and date components from timestamps.
  * `DATE()` – casting timestamps to date type.
  * `DATE_DIFF()` – calculating the number of days between two dates (e.g., delivery duration).
* **Joins:**
  * `JOIN` / `INNER JOIN` across orders, customers, orders_items, and payments to combine data from multiple tables.
  * Multi-table joins (3+ tables) to answer questions requiring combined context (e.g., freight value by customer state).
* **Table aliasing:** Using short aliases (`o`, `c`, `oi`, `p`) for readability in multi-join queries.
* **Comparative/ranked analysis:** Identifying top-N and bottom-N results (e.g., top 5 states by freight cost, top 5 states by delivery time) using `ORDER BY ... DESC / ASC`.
* **Time-series aggregation:** Grouping by year and month to observe trends in order volume and payment behavior over time.
* **Business-question-driven query design:** Translating open-ended business questions into structured SQL logic.

---

## 🔍 Analysis Performed
1. Initial data exploration of customers and geolocation tables
2. Time range of order activity (min/max order timestamps)
3. Cities and states of customers who ordered in a given year
4. Peak order hours (extracting hour from purchase timestamp)
5. Month-on-month order volume trend
6. Distribution of customers across Brazilian states
7. Delivery time vs. estimated delivery date (on-time vs. late analysis)
8. Top/bottom states by average freight value
9. Top/bottom states by average delivery time
10. Order count by number of payment installments
11. Order count by payment type, broken down by year and month

---

## 📈 Key Findings

### 📌 1. Time Range of Operations
* Orders were placed between **04 Sep 2016 and 17 Oct 2018** — roughly a 2-year operating window.

### 📌 2. Order Growth Trend
* Order volume was near zero in the first month (Sep 2016: 4 orders) and ramped up sharply the following month (Oct 2016: 324 orders), indicating the platform was in an early growth/launch phase during late 2016.

### 📌 3. Peak Ordering Hours
* The busiest hours for placing orders were **4 PM** (6,675 orders), **11 AM** (6,578 orders), and **2 PM** (6,569 orders) — customers are most active in the afternoon.

### 📌 4. Customer Geographic Concentration
* **São Paulo (SP)** is by far the largest customer base with 15,540 unique customers, followed by Rio de Janeiro (RJ) with 6,882 and Belo Horizonte (MG) with 2,773.
* Customers who ordered in 2018 were overwhelmingly based in São Paulo, SP, confirming SP as the core, most consistent market.

### 📌 5. Delivery Performance
* Actual delivery times vary widely (e.g., 30–36 days for some orders).
* The gap between actual and estimated delivery dates shows mixed reliability — some orders arrived well ahead of schedule (up to 12 days early) while others were significantly late (up to 29 days late), signaling inconsistent logistics performance.
* **São Paulo (SP)** has the fastest average delivery time among states, at roughly 8 days 16 hours.

### 📌 6. Freight Cost by Region
* The states with the highest average freight value are remote/less-populated regions: **RR (~₹42.98)**, **PB (~₹42.72)**, and **RO (~₹41.07)** — confirming that distance from major distribution hubs drives up shipping cost.

### 📌 7. Payment Behavior
* The vast majority of orders are paid in a single installment (**49,060 orders**), with a much smaller share split into 2 installments (12,389 orders) — most customers prefer to pay in full upfront.
* Alternative payment types (e.g., UPI) appear in low volumes early on (63 orders in Oct 2016), suggesting limited early adoption of non-standard payment methods.

---

## 💡 Summary Insight
São Paulo dominates both the customer base and order volume, delivery reliability is inconsistent enough to warrant logistics review, freight costs scale with regional remoteness, and one-time full payment is the overwhelmingly preferred payment behavior.
