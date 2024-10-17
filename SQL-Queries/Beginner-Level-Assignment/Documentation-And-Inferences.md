# RetailMart Data Analysis - Inferences and Insights ( Beginner Assignment )

<br />

## Table of Contents

- #### [Use Case](#heading-use-case)

- #### [Diagram](#heading-tables-and-relationships-diagram)

- #### [SQL Queries](#heading-sql-queries)

  1.  [_Select all campaigns that are currently active._](#query-1)

  2.  [_Select all customers who joined after January 1, 2023._](#query-2)

  3.  [_Select the total amount spent by each customer, ordered by amount in descending order._](#query-3)

  4.  [_Select the products with a price greater than $50._](#query-4)

  5.  [_Select the number of orders placed in the last 30 days._](#query-5)

  6.  [_Order the products by price in ascending order and limit the results to the top 5 most affordable products._](#query-6)

  7.  [_Select the campaign names and their budgets._](#query-7)

  8.  [_Select the total quantity sold for each product, ordered by quantity sold in descending order._](#query-8)

  9.  [_Select the details of orders that have a total amount greater than $100._](#query-9)

  10. [_Find the total number of customers who have made at least one purchase._](#query-10)

  11. [_Select the top 3 campaigns with the highest budgets._](#query-11)

  12. [_Select the top 5 customers with the highest total amount spent._](#query-12)

- #### [Plan of Actions with respect to different segments](#heading-plans-od-actions)

  1. [_Campaign Effectiveness on Sales_](#segment-1)

     - [Key Findings](#segment-1-key-findings)
     - [Top 3 Actionable Insights](#segment-1-actionable-insights)

  2. [_Campaign Effectiveness on Sales_](#segment-2)

     - [Key Findings](#segment-2-key-findings)
     - [Top 3 Actionable Insights](#segment-2-actionable-insights)

  3. [_Campaign Effectiveness on Sales_](#segment-3)

     - [Key Findings](#segment-3-key-findings)
     - [Top 3 Actionable Insights](#segment-3-actionable-insights)

  4. [_Campaign Effectiveness on Sales_](#segment-4)
     - [Key Findings](#segment-4-key-findings)
     - [Top 3 Actionable Insights](#segment-4-actionable-insights)

- #### [Conclusion](#heading-use-case)

<a id="heading-use-case"></a>

## Use Case

RetailMart wants to evaluate the effectiveness of its recent sales campaigns. They have multiple campaigns running across various regions and want to analyze the impact of these campaigns on sales, customer engagement, and inventory.

<a id="heading-tables-and-relationships-diagram"></a>

<br />

## Tables and Relationships Diagram

<img title="Tables and Relationships" alt="Alt text" src="../../Diagrams/Tables-And-Relationships.png">

<br />

<a id="heading-sql-queries"></a>

## SQL Queries

<a id="query-1"></a>
**Question No. 1:**

_Select all campaigns that are currently active._

```
SELECT * FROM tbl_campaigns
WHERE start_date = CURRENT_DATE AND end_date = CURRENT_DATE;
```

<a id="query-2"></a>
**Question No. 2:**

_Select all customers who joined after January 1, 2023._

```
SELECT * FROM tbl_customers WHERE join_date >'2023-01-01';
```

<a id="query-3"></a>
**Question No. 3:**

_Select the total amount spent by each customer, ordered by amount in descending order._

```
SELECT
	customer_id,
	name,
	ROUND(total_spent, 2) AS Total_Spent_In_Descending
FROM tbl_customers
ORDER BY Total_Spent_In_Descending DESC;
```

<a id="query-4"></a>
**Question No. 4:**

_Select the products with a price greater than $50._

```
SELECT
	product_id,
	product_name,
	price
FROM tbl_products
WHERE price > 50;
```

<a id="query-5"></a>
**Question No. 5:**

_Select the number of orders placed in the last 30 days._

```
SELECT COUNT(*) AS orders_count
FROM tbl_orders
WHERE order_date > CURRENT_DATE - 30;
```

<a id="query-6"></a>
**Question No. 6:**

_Order the products by price in ascending order and limit the results to the top 5 most affordable products._

```
SELECT
	product_id,
	product_name,
	price
FROM tbl_products
ORDER BY price ASC
LIMIT 5;
```

<a id="query-7"></a>
**Question No. 7:**

_Select the campaign names and their budgets._

```
SELECT DISTINCT
	campaign_name,
	budget
FROM tbl_campaigns;
```

<a id="query-8"></a>
**Question No. 8:**

_Select the total quantity sold for each product, ordered by quantity sold in descending order._

```
SELECT
	product_id,
	SUM(quantity) AS total_quantity_sold
FROM tbl_order_items
GROUP BY product_id
ORDER BY total_quantity_sold DESC;
```

<a id="query-9"></a>
**Question No. 9:**

_Select the details of orders that have a total amount greater than $100._

```
SELECT
	order_id,
	customer_id,
	total_amount,
	order_date
FROM tbl_orders
WHERE total_amount > 100;
```

<a id="query-10"></a>
**Question No. 10:**

_Find the total number of customers who have made at least one purchase._

```
SELECT COUNT(*) as customer_count
FROM tbl_customers
JOIN tbl_orders
ON tbl_customers.customer_id = tbl_orders.customer_id;
```

<a id="query-11"></a>
**Question No. 11:**

_Select the top 3 campaigns with the highest budgets._

```
SELECT
	campaign_id,
	campaign_name,
	budget
FROM tbl_campaigns
ORDER BY budget DESC
LIMIT 3;
```

<a id="query-12"></a>
**Question No. 12:**

_Select the top 5 customers with the highest total amount spent._

```
SELECT
	customer_id,
	name,
	total_spent
FROM tbl_customers
ORDER BY total_spent DESC
LIMIT 5;
```

<br />

<a id="heading-plans-od-actions"></a>

## Plans of Actions with respect to different segments

<a id="segment-1"></a>

### 1. Campaign Effectiveness on Sales

<a id="segment-1-key-findings"></a>

#### Key Findings:

1. **Active Campaigns**: Currently running campaigns are trackable via `start_date` and `end_date` filters [(Query 1)](#query-1).
2. **Campaign Budgets**: RetailMart’s highest-budget campaigns can be identified and evaluated [(Query 11)](#query-11).
3. **Campaigns and Product Sales**: Campaigns can be tied to specific products via the `campaign_id` in the orders [(Query 9) and product-campaign mapping](#query-9)
4. **High-Budget Campaign ROI**: Campaigns with high budgets may not always correlate with high returns, so ROI can be tracked [(Query 11)](#query-11).
5. **Campaign Effectiveness by Region**: Campaigns can be filtered by `region`, allowing RetailMart to analyze geographic performance [(Query 11)](#query-11).

<a id="segment-1-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Optimize High-Budget Campaigns**: Review ROI for high-budget campaigns and adjust marketing efforts if returns are underwhelming [(Query 11)](#query-11).
2. **Target Ongoing Campaigns with Boosters**: Implement real-time adjustments, like flash sales, in regions where active campaigns are underperforming [(Query 1)](#query-1).
3. **Regional Campaign Strategy**: Tailor campaign messages and offers based on regional performance to maximize local engagement [(Query 11)](#query-11).

<a id="segment-2"></a>

### 2. Customer Engagement

<a id="segment-2-key-findings"></a>

#### Key Findings:

1. **Customer Spend Patterns**: Total customer spend can be tracked and ranked by descending order to highlight top customers [(Query 3)](#query-3).
2. **New Customer Acquisition**: RetailMart can identify customers who joined after a specific date, such as post-January 2023 [(Query 2)](#query-2).
3. **Customer Order Frequency**: The total number of customers making at least one purchase can be calculated [(Query 10)](#query-10).
4. **Top-Spending Customers**: RetailMart can highlight the top 5% of customers based on total spend [(Query 12)](#query-12).
5. **Customer Churn Risk**: Customers who have not made a purchase in over 30 days can be identified and re-engaged [(modification of Query 5)](#query-5).

<a id="segment-2-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Reward High-Spending Customers**: Launch exclusive offers or loyalty programs to retain the top 5% of high-value customers [(Reference: Query 12)](#query-12).
2. **Re-Engage Dormant Customers**: Implement personalized reactivation campaigns for customers who haven’t made purchases recently [(Reference: modified Query 5)](#query-5).
3. **Segment-Based Campaigns**: Use customer spending data to create tailored marketing campaigns that cater to the interests of different customer segments [(Reference: Query 3)](#query-3).

<a id="segment-3"></a>

### 3. Inventory Management and Product Performance

<a id="segment-3-key-findings"></a>

#### Key Findings:

1. **Low-Stock Products**: Products with stock levels below 20 units can be flagged for restocking [(Query 6)](#query-6).
2. **High-Demand Products**: Total product quantity sold can be tracked to determine which products are in high demand [(Query 8)](#query-8).
3. **Product Price Ranking**: Products can be ranked by price, allowing RetailMart to see top-selling products by price point [(Query 4)](#query-4) and [(Query 6)](#query-6).
4. **Top 10 Products by Sales**: The top 10 products with the highest sales amount can be identified and prioritized for campaigns (previous fixed queries).
5. **Product Performance per Campaign**: By linking `order_items` to `campaign_id`, product performance within specific campaigns can be assessed.

<a id="segment-3-actionable-insights"></a>

#### Top 3 Actionable Insights:

1. **Restock High-Demand Products**: Ensure high-selling products are always in stock, especially during campaigns, to avoid missed sales opportunities [(Query 6)](#query-6).
2. **Bundle Slow-Moving Stock**: Run promotions to bundle slower-moving products with popular items to clear stock and boost overall sales [(Query 8)](#query-8).
3. **Target High-Margin Products**: Promote products with high margins that are also performing well in sales to maximize profits during campaigns (Reference: previous sales queries).

<a id="segment-4"></a>

### 4. Sales Performance Evaluation

<a id="segment-4-key-findings"></a>

#### Key Findings:

1. **Order Volume**: Total orders placed in the last 30 days can be tracked to measure recent sales activity [(Query 5)](#query-5).
2. **High-Value Orders**: Orders with total amounts greater than $100 can be identified for analysis [(Query 9)](#query-9).
3. **Sales by Campaign**: Sales data for each campaign can be assessed by linking `tbl_orders` and `tbl_campaigns` through `campaign_id` (fixed campaign sales queries).
4. **Sales by Region**: Sales trends can be analyzed by region, allowing for performance comparison across geographic areas [(Query 9 modification)](#query-9).
5. **Order Trends Over Time**: RetailMart can track order frequency trends over different time periods to optimize campaign timing [(Query 5)](#query-5).

<a id="segment-4-actionable-insights"></a>

### Top 3 Actionable Insights:

1. **Launch Periodic Flash Sales**: Based on high-order periods, RetailMart should introduce periodic flash sales to capitalize on peak buying times [(Query 5)](#query-5).
2. **Focus on High-Value Orders**: Identify high-value customers and create premium packages or offers tailored to their purchasing behavior [(Query 9)](#query-9).
3. **Track Sales by Region**: Use regional sales performance data to localize marketing efforts, tailoring campaigns to boost sales in underperforming areas [(Query 9)](#query-9).
