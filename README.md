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

## 🔍 Analysis Performed & SQL Queries
*Click on any business question below to view the SQL implementation query logic and execution results.*

<details>
  <summary><b>1. Initial data exploration of customers and geolocation tables</b></summary>
  <br>
  
  ```sql
  -- Exploration of customers table
  select * 
  from `target-500311.Target_Sql.customers` 
  limit 10;

  -- Exploration of geolocation table
  select * 
  from `target-500311.Target_Sql.geolocation` 
  limit 5;
  ```
  
  ![Initial Data Exploration](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>2. Time range of order activity (min/max order timestamps)</b></summary>
  <br>
  
  ```sql
  -- Get the time range between which the orders were placed
  select 
    min(order_purchase_timestamp) as start_time,
    max(order_purchase_timestamp) as end_time
  from `target-500311.Target_Sql.orders`;
  ```
  
  ![Time Range Activity](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>3. Cities and states of customers who ordered in a given year</b></summary>
  <br>
  
  ```sql
  -- Count the Cities & States of customers who ordered during the given period.
  SELECT 
    c.customer_city, 
    c.customer_state
  FROM `target-500311.Target_Sql.orders` as o
  JOIN `target-500311.Target_Sql.customers` as c
    ON o.customer_id = c.customer_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018;
  ```
  
  ![Customer Cities and States 2018](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>4. Peak order hours (extracting hour from purchase timestamp)</b></summary>
  <br>
  
  ```sql
  SELECT 
    EXTRACT(hour FROM order_purchase_timestamp) as time,
    COUNT(order_id) as order_num
  FROM `target-500311.Target_Sql.orders`
  GROUP BY EXTRACT(hour from order_purchase_timestamp)
  ORDER BY order_num desc;
  ```
  
  ![Peak Order Hours](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>5. Month-on-month order volume trend</b></summary>
  <br>
  
  ```sql
  -- Is there a growing trend in the no. of orders placed over the past years?
  SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) as month,
    COUNT(order_id) as order_num
  FROM `target-500311.Target_Sql.orders`
  GROUP BY EXTRACT(month from order_purchase_timestamp)
  ORDER BY order_num desc;

  -- Get the month on month no. of orders broken down by chronological year.
  SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) as month,
    EXTRACT(YEAR FROM order_purchase_timestamp) as year,
    COUNT(*) as num_orders
  FROM `target-500311.Target_Sql.orders`
  GROUP BY year, month;
  ```
  
  ![Month on Month Growth Trend](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>6. Distribution of customers across Brazilian states</b></summary>
  <br>
  
  ```sql
  -- Distribution of customers across the state of brazil
  SELECT customer_city, customer_state,
  COUNT(DISTINCT customer_id) as customer_count
  FROM `target-500311.Target_Sql.customers`
  GROUP BY customer_city, customer_state
  ORDER BY customer_count DESC;
  ```
  
  ![Customer Distribution Across States](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>7. Delivery time vs. estimated delivery date (on-time vs. late analysis)</b></summary>
  <br>
  
  ```sql
  -- Calculate days between purchasing, deliveries and estimated delivery
  select
  date_diff(date(order_delivered_customer_date),date(order_purchase_timestamp),day)as days_to_delivery,
  date_diff(date(order_delivered_customer_date),date(order_estimated_delivery_date),day)as diff_estimated_delivery
  from `target-500311.Target_Sql.orders`;
  ```
  
  ![Delivery Performance Metrics](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>8. Top/bottom states by average freight value</b></summary>
  <br>
  
  ```sql
  -- Find out the top 5 states with highest & lowest average freight value
  select c.customer_state,
  avg(freight_value)as avg_freight_value
  from `target-500311.Target_Sql.orders` as o
  join `target-500311.Target_Sql.orders_items` as oi
    on o.order_id = oi.order_id
  join `target-500311.Target_Sql.customers` as c
    on o.customer_id = c.customer_id
  group by c.customer_state
  order by avg_freight_value desc;
  ```
  
  ![Average Freight Value by Region](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>9. Top/bottom states by average delivery time</b></summary>
  <br>
  
  ```sql
  -- Find out the top 5 states with the lowest average delivery time.
  select
  c.customer_state,
  avg(extract(date from o.order_delivered_customer_date)-extract(date from o.order_purchase_timestamp))as avg_time_to_delivery
  from `target-500311.Target_Sql.orders`as o
  join `target-500311.Target_Sql.orders_items`as oi
    on o.order_id = oi.order_id
  join `target-500311.Target_Sql.customers`as c
    on o.customer_id = c.customer_id
  group by c.customer_state
  order by avg_time_to_delivery asc;
  ```
  
  ![Average Delivery Time Analysis](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>10. Order count by number of payment installments</b></summary>
  <br>
  
  ```sql
  -- count of orders based on the number of payment installments.
  select payment_installments,
  count(distinct order_id) as num_orders
  from `target-500311.Target_Sql.payments`
  group by payment_installments;
  ```
  
  ![Order Count by Payment Installments](PASTE_SCREENSHOT_LINK_HERE)
</details>

<details>
  <summary><b>11. Order count by payment type, broken down by year and month</b></summary>
  <br>
  
  ```sql
  select
  payment_type,
  extract(year from order_purchase_timestamp)as year,
  extract(month from order_purchase_timestamp)as month,
  count(distinct o.order_id)as order_count
  from `target-500311.Target_Sql.orders`as o
  inner join `target-500311.Target_Sql.payments`as p
  on o.order_id = p.order_id
  group by payment_type,year,month
  order by payment_type,year,month;
  ```
  
  ![Payment Type Distribution and Trends](PASTE_SCREENSHOT_LINK_HERE)
</details>

---

## 📈 Key Findings

### 📌 1. Time Range of Operations
* Orders were placed between **04 Sep 2016 and 17 Oct 2018** — roughly a 2-year operating window.

### 📌 2. Order Growth Trend
* Order volume was near zero in the first month (Sep 2016: 4 orders) and ramped up sharply the following month (Oct 2016: 324 orders), indicating the platform was in an early growth/launch phase during late 2016.

### 📌 3. Peak Ordering Hours
* The busiest hours for placing orders were **4 PM** (6,675 orders), **11 AM** (6,578 orders), and **2 PM** (6,569 orders) — customers are most active in the afternoon.

### 📌 4. Customer Geographic Concentration
