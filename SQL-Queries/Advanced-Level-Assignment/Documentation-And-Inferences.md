# RetailMart Data Analysis - Inferences and Insights (Advanced Assignment)

<br />

## Table of Contents

- #### [Use Case](#heading-use-case)

- #### [Diagram](#heading-tables-and-relationships-diagram)

- #### [SQL Queries](#heading-sql-queries)

  1.  [_Select the campaigns with the highest and lowest budgets._](#query-1)

  2.  [_Find the average price of products across all categories._](#query-2)

  3.  [_Rank products based on their total sales within each category._](#query-3)

  4.  [_Create a CTE to calculate the total revenue and average order amount for each campaign._](#query-4)

  5.  [_Handle any missing stock quantities and provide a default value of 0 for products with no recorded inventory._](#query-5)

  6.  [_Analyze the total quantity and revenue generated from each product by customer._](#query-6)

  7.  [_Find campaigns that have a higher average order amount than the overall average._](#query-7)

  8.  [_Analyze the rolling average of sales per campaign over the last 3 months._](#query-8)

  9.  [_Calculate the growth rate of sales for each campaign over time and rank them accordingly._](#query-9)

  10. [_Use CTEs and Window Functions to find the top 5 customers who have consistently spent above the 75th percentile of customer spending._](#query-10)

  11. [_Use Advanced Sub-Queries to find the correlation between campaign budgets and total revenue generated._](#query-11)

  12. [_Partition the sales data to compare the performance of different regions and identify any anomalies._](#query-12)

  13. [_Analyze the impact of product categories on campaign success._](#query-13)

  14. [_Compute the moving average of sales per region and analyze trends._](#query-14)

  15. [_Evaluate the effectiveness of campaigns by comparing the pre-campaign and post-campaign average sales._](#query-15)

- #### [Plan of Actions with respect to different segments](#heading-plans-of-actions)

  1. [_Campaign Performance Analysis_](#segment-1)

     - [Key Findings](#segment-1-key-findings)
     - [Top 3 Actionable Insights](#segment-1-actionable-insights)

  2. [_Customer Spending Patterns_](#segment-2)

     - [Key Findings](#segment-2-key-findings)
     - [Top 3 Actionable Insights](#segment-2-actionable-insights)

  3. [_Product Sales and Inventory Insights_](#segment-3)

     - [Key Findings](#segment-3-key-findings)
     - [Top 3 Actionable Insights](#segment-3-actionable-insights)

  4. [_Regional Sales Trends and Anomalies_](#segment-4)
     - [Key Findings](#segment-4-key-findings)
     - [Top 3 Actionable Insights](#segment-4-actionable-insights)

- #### [Conclusion](#heading-use-case)

<a id="heading-use-case"></a>

## Use Case

RetailMart aims to analyze its sales, campaigns, and customer behaviors. The goal is to uncover insights related to campaign effectiveness, customer spending patterns, product sales, and regional trends to optimize sales strategies.

<a id="heading-tables-and-relationships-diagram"></a>

<br />

## Tables and Relationships Diagram

<img title="Tables and Relationships" alt="Alt text" src="../../Diagrams/Tables-And-Relationships.png">

<br />

<a id="heading-sql-queries"></a>

## SQL Queries

<a id="query-1"></a>
**Question No. 1:**

_Select the campaigns with the highest and lowest budgets._

```
CREATE INDEX idx_campaigns_budget ON tbl_campaigns(budget);

SELECT campaign_name, budget FROM tbl_campaigns
ORDER BY budget DESC LIMIT 1;

SELECT campaign_name, budget FROM tbl_campaigns
ORDER BY budget ASC LIMIT 1;
```

<a id="query-2"></a>
**Question No. 2:**

_Find the average price of products across all categories._

```
CREATE INDEX idx_products_category ON tbl_products(category);

SELECT category, AVG(price) AS avg_price
FROM tbl_products
GROUP BY category;
```

<a id="query-3"></a>
**Question No. 3:**

_Rank products based on their total sales within each category._

```
-- single column index
CREATE INDEX idx_order_items_product_id ON tbl_order_items(product_id);
-- composite index
CREATE INDEX idx_products_category_product_id ON tbl_products(category, product_id);

SELECT Product.category, Product.product_name,
       SUM(Order_Items.quantity) AS total_sales,
       RANK() OVER (PARTITION BY Product.category ORDER BY SUM(Order_Items.quantity) DESC) AS sales_rank
FROM tbl_order_items Order_Items
JOIN tbl_products Product ON Order_Items.product_id = Product.product_id
GROUP BY Product.category, Product.product_name;
```

<a id="query-4"></a>
**Question No. 4:**

_Create a CTE to calculate the total revenue and average order amount for each campaign._

```
CREATE INDEX idx_orders_campaign_id ON tbl_orders(campaign_id);

WITH campaign_revenue AS (
    SELECT campaign_id, SUM(total_amount) AS total_revenue, AVG(total_amount) AS avg_order_amount
    FROM tbl_orders
    GROUP BY campaign_id
)
SELECT campaign_id, total_revenue, avg_order_amount
FROM campaign_revenue;
```

<a id="query-5"></a>
**Question No. 5:**

_Handle any missing stock quantities and provide a default value of 0 for products with no recorded inventory._

```
CREATE INDEX idx_inventory_product_id ON tbl_inventory(product_id);

SELECT Product.product_name, COALESCE(Inventory.stock_quantity, 0) AS stock_quantity
FROM tbl_products Product
LEFT JOIN tbl_inventory Inventory ON Product.product_id = Inventory.product_id;
```

<a id="query-6"></a>
**Question No. 6:**

_Analyze the total quantity and revenue generated from each product by customer._

```
CREATE INDEX idx_orders_customer_id ON tbl_orders(customer_id);

SELECT Customers.name, Products.product_name,
       SUM(Order_Items.quantity) AS total_quantity,
       SUM(Order_Items.quantity * Order_Items.price) AS total_revenue
FROM tbl_order_items Order_Items
JOIN tbl_products Products ON Order_Items.product_id = Products.product_id
JOIN tbl_orders Orders ON Order_Items.order_id = Orders.order_id
JOIN tbl_customers Customers ON Orders.customer_id = Customers.customer_id
GROUP BY Customers.name, Products.product_name;
```

<a id="query-7"></a>
**Question No. 7:**

_Find campaigns that have a higher average order amount than the overall average._

```
WITH avg_order_amount AS (
    SELECT AVG(total_amount) AS overall_avg
    FROM tbl_orders
)
SELECT Campaigns.campaign_name, AVG(Orders.total_amount) AS campaign_avg
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Campaigns.campaign_name
HAVING AVG(Orders.total_amount) > (SELECT overall_avg FROM avg_order_amount);
```

<a id="query-8"></a>
**Question No. 8:**

_Analyze the rolling average of sales per campaign over the last 3 months._

```
CREATE INDEX idx_orders_campaign_id_order_date ON tbl_orders(campaign_id, order_date);

SELECT campaign_id, order_date,
       AVG(total_amount) OVER (PARTITION BY campaign_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM tbl_orders;
```

<a id="query-9"></a>
**Question No. 9:**

_Calculate the growth rate of sales for each campaign over time and rank them accordingly._

```
WITH sales_growth AS (
    SELECT campaign_id, order_date,
           total_amount,
           LAG(total_amount) OVER (PARTITION BY campaign_id ORDER BY order_date) AS prev_amount
    FROM tbl_orders
)
SELECT campaign_id, order_date,
       (total_amount - prev_amount) / prev_amount AS growth_rate
FROM sales_growth
WHERE prev_amount IS NOT NULL;
```

<a id="query-10"></a>
**Question No. 10:**

_Use CTEs and Window Functions to find the top 5 customers who have consistently spent above the 75th percentile of customer spending._

```
-- Create index on total_spent to improve performance
CREATE INDEX idx_customers_total_spent ON tbl_customers(total_spent);

-- First, calculate the 75th percentile of total_spent
WITH percentile_75 AS (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_spent) AS threshold
    FROM tbl_customers
),
-- Select customers who spent more than the 75th percentile
customers_above_75 AS (
    SELECT customer_id, total_spent
    FROM tbl_customers, percentile_75
    WHERE total_spent > percentile_75.threshold
)
-- Rank and return the top 5 customers who spent the most
SELECT customer_id, total_spent
FROM customers_above_75
ORDER BY total_spent DESC
LIMIT 5;
```

<a id="query-11"></a>
**Question No. 11:**

_Use Advanced Sub-Queries to find the correlation between campaign budgets and total revenue generated._

```
SELECT Campaigns.budget, SUM(Orders.total_amount) AS total_revenue
FROM tbl_campaigns Campaigns
JOIN tbl_orders Orders ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY Campaigns.budget;
```

<a id="query-12"></a>
**Question No. 12:**

_Partition the sales data to compare the performance of different regions and identify any anomalies._

```
CREATE INDEX idx_campaigns_region ON tbl_campaigns(region);

SELECT Campaigns.region, SUM(Orders.total_amount) AS total_sales,
       RANK() OVER (PARTITION BY Campaigns.region ORDER BY SUM(Orders.total_amount) DESC) AS region_rank
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Campaigns.region;
```

<a id="query-13"></a>
**Question No. 13:**

_Analyze the impact of product categories on campaign success._

```
SELECT Product.category, Campaigns.campaign_name,
       SUM(Order_Items.quantity * Order_Items.price) AS total_revenue
FROM tbl_order_items Order_Items
JOIN tbl_products Product ON Order_Items.product_id = Product.product_id
JOIN tbl_orders Orders ON Order_Items.order_id = Orders.order_id
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Product.category, Campaigns.campaign_name;
```

<a id="query-14"></a>
**Question No. 14:**

_Compute the moving average of sales per region and analyze trends._

```
SELECT Campaigns.region, Orders.order_date,
       AVG(Orders.total_amount) OVER (PARTITION BY Campaigns.region ORDER BY Orders.order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id;
```

<a id="query-15"></a>
**Question No. 15:**

_Evaluate the effectiveness of campaigns by comparing the pre-campaign and post-campaign average sales._

```
WITH campaign_sales AS (
    SELECT campaign_id, order_date, total_amount,
           CASE
               WHEN order_date < (SELECT MIN(start_date) FROM tbl_campaigns WHERE campaign_id = Orders.campaign_id) THEN 'pre_campaign'
               ELSE 'post_campaign'
           END AS campaign_phase
    FROM tbl_orders Orders
)
SELECT campaign_id, campaign_phase, AVG(total_amount) AS avg_sales
FROM campaign_sales
GROUP BY campaign_id, campaign_phase;
```

<br />

<a id="heading-plans-of-actions"></a>

## Plans of Actions with respect to different segments

<a id="segment-1"></a>

<a id="segment-1"></a>

### 1. Campaign Effectiveness on Sales

<a id="segment-1-key-findings"></a>

#### Key Findings:

1. **Active Campaigns**: Currently running campaigns can be identified and analyzed for effectiveness in driving sales [(Query 1)](#query-1).
2. **Customer Engagement**: The number of new customers joining post-January 2023 indicates the effectiveness of marketing efforts in attracting new clientele [(Query 2)](#query-2).
3. **Revenue Analysis**: The total amount spent by each customer allows for the identification of high-value customers who contribute significantly to revenue [(Query 3)](#query-3).
4. **Product Performance**: Products priced above $50 can highlight premium items that might drive higher sales volumes, which can be essential for marketing strategies [(Query 4)](#query-4).
5. **Sales Trends**: Monitoring orders placed in the last 30 days can provide insights into recent sales trends and customer behavior [(Query 5)](#query-5).

<a id="segment-1-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Optimize Campaign Timing**: Analyze and adjust the timing of campaigns based on the active periods identified to enhance engagement and sales performance [(Query 1)](#query-1).
2. **Target High-Value Customers**: Implement loyalty programs or targeted marketing strategies for customers who frequently spend above average amounts [(Query 3)](#query-3).
3. **Promote High-Priced Products**: Consider launching campaigns that emphasize premium products, leveraging their pricing to attract customers seeking quality [(Query 4)](#query-4).

<a id="segment-2"></a>

### 2. Customer Engagement

<a id="segment-2-key-findings"></a>

#### Key Findings:

1. **Customer Spend Distribution**: Understanding the total spent by each customer can help identify spending patterns and trends [(Query 3)](#query-3).
2. **New Customer Dynamics**: The influx of new customers since January 2023 can provide insights into the effectiveness of recent marketing strategies [(Query 2)](#query-2).
3. **Engagement Rate**: The number of orders in the last 30 days indicates customer engagement and retention levels [(Query 5)](#query-5).
4. **Purchase Behavior**: The identification of the total number of customers who have made purchases helps understand the customer base size and engagement [(Query 10)](#query-10).
5. **High-Spending Customers**: Identifying customers who have spent the most can help tailor marketing strategies to retain these valuable customers [(Query 12)](#query-12).

<a id="segment-2-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Engagement Campaigns for New Customers**: Develop onboarding programs or special offers to engage new customers who joined after January 2023 [(Query 2)](#query-2).
2. **Retention Strategies**: Implement targeted campaigns to retain customers who have previously made purchases, focusing on those who have not ordered recently [(Query 5)](#query-5).
3. **Reward High-Spending Customers**: Create loyalty programs or exclusive offers for high-spending customers to encourage repeat purchases and increase customer lifetime value [(Query 12)](#query-12).

<a id="segment-3"></a>

### 3. Inventory Management and Product Performance

<a id="segment-3-key-findings"></a>

#### Key Findings:

1. **Product Demand Insights**: The total quantity sold for each product reveals which items are in high demand and may require restocking [(Query 8)](#query-8).
2. **Pricing Strategies**: Analyzing products with prices over $50 can help assess the performance of premium products [(Query 4)](#query-4).
3. **Order Trends**: Tracking orders in the last 30 days offers insights into sales trends and seasonal buying patterns [(Query 5)](#query-5).
4. **Top Campaigns**: Identifying the top campaigns with the highest budgets can help evaluate the return on investment (ROI) for marketing initiatives [(Query 11)](#query-11).
5. **Product Performance by Campaign**: Analyzing sales data linked to specific campaigns can uncover which marketing strategies work best for certain products [(Query 9)](#query-9).

<a id="segment-3-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Restock Based on Demand**: Ensure timely restocking of high-demand products to prevent lost sales opportunities [(Query 8)](#query-8).
2. **Bundle Promotions for Slow Movers**: Consider bundling slower-moving products with high-demand items to boost overall sales [(Query 8)](#query-8).
3. **Leverage Successful Campaigns**: Review successful campaigns to replicate strategies in future marketing efforts, especially for high-budget campaigns [(Query 11)](#query-11).

<a id="segment-4"></a>

### 4. Sales Performance Evaluation

<a id="segment-4-key-findings"></a>

#### Key Findings:

1. **Sales Activity Monitoring**: The total orders in the last 30 days provide insights into recent sales performance and activity [(Query 5)](#query-5).
2. **High-Value Transactions**: Orders greater than $100 indicate significant sales opportunities that could be targeted further [(Query 9)](#query-9).
3. **Customer Purchase Patterns**: Identifying customers who have made at least one purchase helps understand overall customer activity and engagement [(Query 10)](#query-10).
4. **Top Campaign Effectiveness**: Analysis of top campaigns reveals which ones are performing best in terms of customer engagement and revenue generation [(Query 11)](#query-11).
5. **Sales by Customer Segment**: Analyzing total spending per customer can help tailor marketing strategies for different customer segments [(Query 12)](#query-12).

<a id="segment-4-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Focus on High-Value Orders**: Develop strategies to target high-value customers, possibly through personalized offers or premium product promotions [(Query 9)](#query-9).
2. **Utilize Sales Data for Future Campaigns**: Leverage insights from the last 30 days of sales data to adjust future marketing strategies for better performance [(Query 5)](#query-5).
3. **Optimize Marketing Budget Allocation**: Allocate marketing budgets more effectively by analyzing which campaigns yield the highest return on investment [(Query 11)](#query-11).
