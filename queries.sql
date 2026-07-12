-- =======================================================================================
-- TARGET BRAZIL E-COMMERCE DATA ANALYSIS
-- Core SQL Scripts for Exploratory Analysis and Business Insights
-- Database Environment: Google BigQuery (Standard SQL)
-- =======================================================================================

-- ---------------------------------------------------------------------------------------
-- 1. INITIAL DATA EXPLORATION
-- ---------------------------------------------------------------------------------------

-- Exploration of the customers table structure and data characteristics
SELECT *
FROM `target-500311.Target_Sql.customers`
LIMIT 10;

-- Exploration of the geolocation table data layout
SELECT *
FROM `target-500311.Target_Sql.geolocation`
LIMIT 5;


-- ---------------------------------------------------------------------------------------
-- 2. OPERATIONAL TIME WINDOW
-- ---------------------------------------------------------------------------------------

-- Get the minimum and maximum time range between which the platform's orders were placed
SELECT
  MIN(order_purchase_timestamp) AS start_time,
  MAX(order_purchase_timestamp) AS end_time
FROM `target-500311.Target_Sql.orders`;


-- ---------------------------------------------------------------------------------------
-- 3. CUSTOMER GEOGRAPHY BY YEAR
-- ---------------------------------------------------------------------------------------

-- Extract and count the unique Cities & States of customers who placed orders in Q1 2018
SELECT
  c.customer_city, 
  c.customer_state
FROM `target-500311.Target_Sql.orders` AS o
JOIN `target-500311.Target_Sql.customers` AS c
  ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
  AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 3;


-- ---------------------------------------------------------------------------------------
-- 4. ORDER VOLUME BY SEASONALITY (MONTHLY RECURRENCE)
-- ---------------------------------------------------------------------------------------

-- Analyze general historical order concentration aggregated purely by month
SELECT
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  COUNT(order_id) AS order_num
FROM `target-500311.Target_Sql.orders`
GROUP BY month
ORDER BY order_num DESC;


-- ---------------------------------------------------------------------------------------
-- 5. PEAK HOURLY TRAFFIC ANALYSIS
-- ---------------------------------------------------------------------------------------

-- Track busiest transactional operational hours to isolate when Brazilian customers order most
SELECT
  EXTRACT(HOUR FROM order_purchase_timestamp) AS time,
  COUNT(order_id) AS order_num
FROM `target-500311.Target_Sql.orders`
GROUP BY time
ORDER BY order_num DESC;


-- ---------------------------------------------------------------------------------------
-- 6. CHRONOLOGICAL MONTH-ON-MONTH (MoM) ORDER VOLUME TREND
-- ---------------------------------------------------------------------------------------

-- Map out sequential order patterns step-by-step across consecutive years and months
SELECT
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
  COUNT(*) AS num_orders
FROM `target-500311.Target_Sql.orders`
GROUP BY year, month
ORDER BY year, month;


-- ---------------------------------------------------------------------------------------
-- 7. GEOGRAPHIC MARKET CONCENTRATION
-- ---------------------------------------------------------------------------------------

-- Track overall distribution metrics of unique customer accounts across regions
SELECT 
  customer_city, 
  customer_state,
  COUNT(DISTINCT customer_id) AS customer_count
FROM `target-500311.Target_Sql.customers`
GROUP BY customer_city, customer_state
ORDER BY customer_count DESC;


-- ---------------------------------------------------------------------------------------
-- 8. YEAR-OVER-YEAR (YoY) COST GROWTH (YTD: JAN TO AUG)
-- ---------------------------------------------------------------------------------------

-- Calculate the exact % growth in sales metrics between 2017 and 2018 for Months Jan-Aug
WITH yearly_totals AS (
  SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(p.payment_value) AS total_payment
  FROM `target-500311.Target_Sql.payments` AS p
  JOIN `target-500311.Target_Sql.orders` AS o
    ON p.order_id = o.order_id
  WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
    AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
  GROUP BY year
),

yearly_comparison AS (
  SELECT
    year,
    total_payment,
    LEAD(total_payment) OVER(ORDER BY year DESC) AS prev_year_payment
  FROM yearly_totals
)

SELECT 
  ROUND(((total_payment - prev_year_payment) / prev_year_payment) * 100, 2) AS pct_increase
FROM yearly_comparison
WHERE prev_year_payment IS NOT NULL;


-- ---------------------------------------------------------------------------------------
-- 9. VALUE MARGINS & LOGISTICS FINANCIALS BY CUSTOMER STATE
-- ---------------------------------------------------------------------------------------

-- Aggregate and break down the mean vs. sum parameters for order values and freight metrics
SELECT
  c.customer_state,
  AVG(price) AS avg_price,
  SUM(price) AS sum_price,
  AVG(freight_value) AS avg_freight,
  SUM(freight_value) AS sum_freight
FROM `target-500311.Target_Sql.orders` AS o
JOIN `target-500311.Target_Sql.orders_items` AS oi
  ON o.order_id = oi.order_id
JOIN `target-500311.Target_Sql.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state;


-- ---------------------------------------------------------------------------------------
-- 10. SHIPPING TIMELINES & ESTIMATE VARIANCE DETECTOR
-- ---------------------------------------------------------------------------------------

-- Quantify precise transit times and variance buffers against original estimate SLAs
SELECT
  DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY) AS days_to_delivery,
  DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS diff_estimated_delivery
FROM `target-500311.Target_Sql.orders`;


-- ---------------------------------------------------------------------------------------
-- 11. REGIONAL FREIGHT VALUE BENCHMARKING (TOP 5 HIGHEST FREIGHT EXPENSES)
-- ---------------------------------------------------------------------------------------

-- Isolate the top 5 costliest geographical regional points based on average shipping spend
SELECT 
  c.customer_state,
  AVG(freight_value) AS avg_freight_value
FROM `target-500311.Target_Sql.orders` AS o
JOIN `target-500311.Target_Sql.orders_items` AS oi
  ON o.order_id = oi.order_id
JOIN `target-500311.Target_Sql.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_freight_value DESC
LIMIT 5;


-- ---------------------------------------------------------------------------------------
-- 12. SUPPLY CHAIN PERFORMANCE OUTLIERS (TOP 5 SLOWEST & FASTEST STATES)
-- ---------------------------------------------------------------------------------------

-- Rank the top 5 states suffering from the highest average overall delivery delays
SELECT 
  c.customer_state,
  AVG(EXTRACT(DATE FROM o.order_delivered_customer_date) - EXTRACT(DATE FROM o.order_purchase_timestamp)) AS avg_time_to_delivery
FROM `target-500311.Target_Sql.orders` AS o
JOIN `target-500311.Target_Sql.orders_items` AS oi
  ON o.order_id = oi.order_id
JOIN `target-500311.Target_Sql.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_time_to_delivery DESC
LIMIT 5;

-- Rank the top 5 operational states maintaining the lowest average shipment delivery times
SELECT 
  c.customer_state,
  AVG(EXTRACT(DATE FROM o.order_delivered_customer_date) - EXTRACT(DATE FROM o.order_purchase_timestamp)) AS avg_time_to_delivery
FROM `target-500311.Target_Sql.orders` AS o
JOIN `target-500311.Target_Sql.orders_items` AS oi
  ON o.order_id = oi.order_id
JOIN `target-500311.Target_Sql.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_time_to_delivery ASC
LIMIT 5;


-- ---------------------------------------------------------------------------------------
-- 13. TIME-SERIES PAYMENT CHANNEL TRENDS
-- ---------------------------------------------------------------------------------------

-- Calculate sequential transaction volumes segmented by available payment options
SELECT
  payment_type,
  EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
  EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id) AS order_count
FROM `target-500311.Target_Sql.orders` AS o
INNER JOIN `target-500311.Target_Sql.payments` AS p
  ON o.order_id = p.order_id
GROUP BY payment_type, year, month
ORDER BY payment_type, year, month;


-- ---------------------------------------------------------------------------------------
-- 14. CREDIT PREFERENCE ANALYSIS (PAYMENT INSTALLMENT FREQUENCY)
-- ---------------------------------------------------------------------------------------

-- Profile user preference metrics based on total chosen financing installment structural splits
SELECT 
  payment_installments,
  COUNT(DISTINCT order_id) AS num_orders
FROM `target-500311.Target_Sql.payments`
GROUP BY payment_installments
ORDER BY payment_installments ASC;
