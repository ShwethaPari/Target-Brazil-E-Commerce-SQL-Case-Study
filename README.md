# 📊 E-Commerce Data Analytics Project: A Target-Style Case Study Using Brazilian Marketplace Data

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
  
  <img width="1476" height="642" alt="Screenshot 2026-07-12 161959" src="https://github.com/user-attachments/assets/952d5148-a128-4ed9-a2e7-938ede303585" />


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

  <img width="1451" height="443" alt="Screenshot 2026-07-12 162212" src="https://github.com/user-attachments/assets/256dd7a2-b050-410a-8269-e19ed0bd0dc4" />

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

  <img width="1458" height="510" alt="Screenshot 2026-07-12 162304" src="https://github.com/user-attachments/assets/c9c72c87-0158-4a2b-a635-b63c03f8f546" />

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
  
  <img width="1445" height="510" alt="Screenshot 2026-07-12 162618" src="https://github.com/user-attachments/assets/742f50a3-8aa6-4e58-8fb6-e0a8f4fdd47e" />

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
  
  <img width="1467" height="511" alt="Screenshot 2026-07-12 162345" src="https://github.com/user-attachments/assets/4de77126-4b2f-4ed6-b57d-ad2da6d90381" />

  <img width="1457" height="520" alt="Screenshot 2026-07-12 162800" src="https://github.com/user-attachments/assets/29429485-a808-40e7-895d-9e12023e942e" />


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
  
  <img width="1468" height="513" alt="Screenshot 2026-07-12 162835" src="https://github.com/user-attachments/assets/af13a639-63ec-4c93-b726-f8c5803d564f" />

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
  
  <img width="1471" height="533" alt="Screenshot 2026-07-12 162943" src="https://github.com/user-attachments/assets/7c30d29b-7588-4c2e-b792-8e579e99bd8f" />

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
  
  <img width="1455" height="525" alt="Screenshot 2026-07-12 163034" src="https://github.com/user-attachments/assets/ccada372-ce22-437c-bbf0-1e4ac0ebdd6b" />

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
  
  <img width="1456" height="485" alt="Screenshot 2026-07-12 163315" src="https://github.com/user-attachments/assets/fe36f08a-5dcd-4745-bdcd-c63883c260d3" />

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
  
  <img width="1475" height="515" alt="Screenshot 2026-07-12 163108" src="https://github.com/user-attachments/assets/607dea17-838f-4fbc-bf00-5a66672e5c16" />

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
  
  <img width="1473" height="548" alt="Screenshot 2026-07-12 163215" src="https://github.com/user-attachments/assets/f1ddfeff-180c-4117-8a76-57c1f3caabd1" />

</details>

---

## 📈 Key Findings

### 📌 1. Time Range of Operations
Orders were placed between **04 Sep 2016** and **17 Oct 2018**, spanning approximately **2 years** of platform operations.

---

### 📌 2. Order Growth Trend
- The platform started with only **4 orders** in **September 2016**.
- Orders increased sharply to **324** in **October 2016**.
- Activity then dropped again (**1 order** in **December 2016**), suggesting an initial **pilot/testing phase**.
- Consistent order growth began afterward, indicating the platform's transition into regular business operations.

---

### 📌 3. Peak Ordering Hours
Customers were most active during the afternoon:

| Rank | Hour | Orders |
|------|------|-------:|
| 🥇 1 | **4 PM** | **6,675** |
| 🥈 2 | **11 AM** | **6,578** |
| 🥉 3 | **2 PM** | **6,569** |

**Business Insight:**  
Customer purchasing activity is highest between **11 AM and 4 PM**, making this an ideal window for promotions, flash sales, and marketing campaigns.

---

### 📌 4. Seasonal Order Concentration
Highest order volumes (aggregated across all years):

| Month | Orders |
|--------|-------:|
| **August** | **10,843** |
| **May** | **10,573** |
| **July** | **10,318** |

**Business Insight:**  
Demand peaks during the **mid-year period**, rather than the traditional holiday season (November–December).

---

### 📌 5. Customer Geographic Concentration
Top customer locations:

| City / State | Customers |
|---------------|----------:|
| **São Paulo (SP)** | **15,540** |
| **Rio de Janeiro (RJ)** | **6,882** |
| **Belo Horizonte (MG)** | **2,773** |

**Business Insight:**  
Most customers are concentrated in Brazil's **Southeast region**, reflecting higher population density and stronger market demand.

---

### 📌 6. Average Freight Cost by State
States with the highest average freight costs:

| State | Avg. Freight Cost |
|--------|------------------:|
| **RR (Roraima)** | **R$42.98** |
| **PB (Paraíba)** | **R$42.72** |
| **RO (Rondônia)** | **R$41.07** |

**Business Insight:**  
Remote and northern states incur higher shipping costs due to longer transportation distances from major distribution centers.

---

### 📌 7. Payment Installment Preference

| Installments | Orders |
|--------------|-------:|
| **1 Installment** | **49,060** |
| **2 Installments** | **12,389** |

**Business Insight:**  
Most customers prefer **paying in full**, while installment payments are considerably less common.

---

## 📊 Overall Business Insights

- 📈 The platform experienced rapid growth after an initial testing period.
- ⏰ Customer purchases are concentrated during **late morning to afternoon**.
- 🌤️ Demand peaks during the **mid-year months (May–August)**.
- 📍 The customer base is heavily concentrated in **Southeast Brazil**.
- 🚚 Freight costs increase significantly for **remote northern states**.
- 💳 Most customers prefer **single-installment payments**, indicating strong upfront purchasing behavior.
