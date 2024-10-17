# RetailMart Data Analysis - Inferences and Insights ( Beginner Assignment )

<br />

## Table of Contents

- #### [Use Case](#heading-use-case)

- #### [Diagram](#heading-tables-and-relationships-diagram)

- #### [SQL Queries](#heading-sql-queries)

  1.  [_Select the number of orders per campaign and order by the number of orders in descending order._](#query-1)

  2.  [_Find the average order amount for each campaign._](#query-2)

  3.  [_Select the products that have been ordered more than 100 times in total._](#query-3)

  4.  [_Find the total sales for each region and order by sales in descending order._](#query-4)

  5.  [_Select the average amount spent per customer and order by this average in descending order._](#query-5)

  6.  [_Select the most popular product in each category._](#query-6)

  7.  [_Find the total budget of all campaigns that have ended._](#query-7)

  8.  [_Get order details along with campaign names._](#query-8)

  9.  [_Get product details for each order item._](#query-9)

  10. [_Aggregate the total revenue per campaign._](#query-10)

  11. [_Find the total number of orders placed per region._](#query-11)

  12. [_Find the total amount spent by each customer on each campaign._](#query-12)

  13. [_Use Aggregate Functions to find the average budget of all campaigns and group by region._](#query-13)

  14. [_Filter campaigns with a total spending greater than their budget using a sub-query._](#query-14)

  15. [_Calculate the total quantity sold and average price per product._](#query-15)

  16. [_Aggregate the total quantity sold per product._](#query-16)

  17. [_Find campaigns with an average order amount greater than $200._](#query-17)

  18. [_Find the top 10 products with the highest total sales amount and order by sales in descending order._](#query-18)

  19. [_Find products with less than 20 units in stock and order it using stock quantity._](#query-19)

  20. [_Find customers who spent more than the average amount spent per customer in the last 6 months._](#query-20)

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

_Find the average order amount for each campaign._

```
SELECT
	campaign_id,
	ROUND(AVG(total_amount), 2) AS average_order_amount
FROM
	tbl_orders
GROUP BY
	campaign_id;
```

<a id="query-3"></a>
**Question No. 3:**

_Select the products that have been ordered more than 100 times in total._

```
SELECT
	Products.product_id AS product_id,
	Products.product_name AS product_name,
	SUM(Order_Items.quantity) AS total_quantity
FROM
	tbl_products Products
	LEFT JOIN tbl_order_items Order_Items
ON
	Products.product_id = Order_Items.product_id
GROUP BY
	Products.product_id, Products.product_name
HAVING
	SUM(Order_Items.quantity) > 100;
```

<a id="query-4"></a>
**Question No. 4:**

_Find the total sales for each region and order by sales in descending order._

```
SELECT
	Campaigns.region,
	SUM(Orders.total_amount) AS total_sales
FROM
	tbl_campaigns Campaigns
	JOIN tbl_orders Orders
ON
	Campaigns.campaign_id = Orders.campaign_id
GROUP BY
	Campaigns.region
ORDER BY
	total_sales DESC;
```

<a id="query-5"></a>
**Question No. 5:**

_Select the average amount spent per customer and order by this average in descending order._

```
SELECT
	Customers.customer_id,
	Customers.name,
	ROUND(AVG(Orders.total_amount), 2) AS avg_amount_spent
FROM
	tbl_customers Customers
	JOIN tbl_orders Orders
ON
	Customers.customer_id = Orders.customer_id
GROUP BY
	Customers.customer_id, Customers.name
ORDER BY
	avg_amount_spent DESC;
```

<a id="query-6"></a>
**Question No. 6:**

_Select the most popular product in each category._

```
WITH product_totals AS (
    -- Step 1: Calculate total quantity sold for each product
	-- Total Quantity = No. of orders places along with No. of Units per order
	-- Count = No of orders places, Sum = No. of orders places along with No. of Units per order
    SELECT
		Order_Items.product_id,
		Product.category,
		Product.product_name,
		SUM(Order_Items.quantity) AS total_quantity
    FROM
		tbl_order_items Order_Items
		JOIN tbl_products Product
	ON
		Order_Items.product_id = Product.product_id
    GROUP BY Order_Items.product_id, Product.category, Product.product_name
),
category_max AS (
    -- Step 2: Get the maximum total quantity for each category from the product_totals CTE
    SELECT
		category,
		MAX(total_quantity) AS max_quantity
    FROM
		product_totals
    GROUP BY
		category
)
-- Step 3: Join the two results to get the most popular product in each category
SELECT
	Product_Totals.category,
	Product_Totals.product_name,
	Product_Totals.total_quantity AS max_quantity
FROM
	product_totals Product_Totals
	JOIN category_max Category_Max
ON
	(Product_Totals.category = Category_Max.category)
	AND (Product_Totals.total_quantity = Category_Max.max_quantity)
ORDER BY
	Product_Totals.category;
```

<a id="query-7"></a>
**Question No. 7:**

_Find the total budget of all campaigns that have ended.._

```
SELECT
	SUM(budget) AS total_budget
FROM
	tbl_campaigns
WHERE
	end_date < CURRENT_DATE;
```

<a id="query-8"></a>
**Question No. 8:**

_Get order details along with campaign names._

```
SELECT
    Orders.order_id,
    Orders.customer_id,
    Orders.order_date,
    Orders.total_amount,
    Campaigns.campaign_name
FROM
	tbl_orders Orders
	JOIN tbl_campaigns Campaigns
ON
	Orders.campaign_id = Campaigns.campaign_id;
```

<a id="query-9"></a>
**Question No. 9:**

_Get product details for each order item._

```
SELECT
    Order_Items.order_item_id,
    Order_Items.order_id,
    Order_Items.product_id,
    Products.product_name,
    Products.category,
    Products.price AS product_price,
    Order_Items.quantity,
    Order_Items.price AS order_item_price,
    Orders.order_date,
    Orders.total_amount
FROM
	tbl_order_items Order_Items
	JOIN tbl_products Products
ON Order_Items.product_id = Products.product_id
	JOIN tbl_orders Orders
ON Order_Items.order_id = Orders.order_id;
```

<a id="query-10"></a>
**Question No. 10:**

_Aggregate the total revenue per campaign._

```
SELECT
    Campaigns.campaign_id,
    Campaigns.campaign_name,
    SUM(Orders.total_amount) AS total_revenue
FROM tbl_campaigns Campaigns LEFT JOIN tbl_orders Orders
	ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY
    Campaigns.campaign_id, Campaigns.campaign_name;
```

<a id="query-11"></a>
**Question No. 11:**

_Find the total number of orders placed per region._

```
SELECT
    Campaigns.region,
    COUNT(Orders.order_id) AS total_orders
FROM
    tbl_campaigns Campaigns
LEFT JOIN tbl_orders Orders ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY Campaigns.region;
```

<a id="query-12"></a>
**Question No. 12:**

_Find the total amount spent by each customer on each campaign._

```
SELECT
    Customer.customer_id,
    Customer.name AS customer_name,
    Campaigns.campaign_id,
    Campaigns.campaign_name,
    SUM(Orders.total_amount) AS total_spent
FROM
	tbl_customers Customer
JOIN tbl_orders Orders
	ON Customer.customer_id = Orders.customer_id
JOIN tbl_campaigns Campaigns
	ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY
    Customer.customer_id, Customer.name, Campaigns.campaign_id, Campaigns.campaign_name
```

<a id="query-13"></a>
**Question No. 13:**

_Use Aggregate Functions to find the average budget of all campaigns and group by region._

```
SELECT
    region,
    ROUND(AVG(budget), 2) AS average_budget
FROM
    tbl_campaigns
GROUP BY
    region;
```

<a id="query-14"></a>
**Question No. 14:**

_Filter campaigns with a total spending greater than their budget using a sub-query._

```
SELECT
    Campaigns.campaign_id,
    Campaigns.campaign_name,
    Campaigns.budget,
    Total_Spent.total_amount AS total_spending
FROM
    tbl_campaigns Campaigns
JOIN (
	SELECT
		campaign_id, SUM(total_amount) AS total_amount
	FROM
		tbl_orders
	GROUP BY
		campaign_id
) AS Total_Spent ON Campaigns.campaign_id = Total_Spent.campaign_id
WHERE
    Total_Spent.total_amount > Campaigns.budget;
```

<a id="query-15"></a>
**Question No. 15:**

_Calculate the total quantity sold and average price per product._

```
SELECT
    Products.product_id,
    Products.product_name,
    SUM(Order_items.quantity) AS total_quantity_sold,
    AVG(Products.price) AS average_price
FROM
    tbl_products Products
LEFT JOIN
    tbl_order_items Order_items ON Products.product_id = Order_items.product_id
GROUP BY
    Products.product_id, Products.product_name;
```

<a id="query-16"></a>
**Question No. 16:**

_Aggregate the total quantity sold per product._

```
SELECT
    Order_Items.product_id,
    Products.product_name,
    SUM(Order_Items.quantity) AS total_quantity_sold
FROM
    tbl_order_items Order_items
JOIN
    tbl_products Products ON Order_Items.product_id = Products.product_id
GROUP BY
    Order_Items.product_id, Products.product_name;
```

<a id="query-17"></a>
**Question No. 17:**

_Find campaigns with an average order amount greater than $200._

```
SELECT
    Campaigns.campaign_id,
    Campaigns.campaign_name,
    AVG(Orders.total_amount) AS average_order_amount
FROM
    tbl_campaigns Campaigns
JOIN
    tbl_orders Orders ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY
    Campaigns.campaign_id, Campaigns.campaign_name
HAVING
    AVG(Orders.total_amount) > 200;
```

<a id="query-18"></a>
**Question No. 18:**

_Find the top 10 products with the highest total sales amount and order by sales in descending order._

```
SELECT
    Products.product_id,
    Products.product_name,
    SUM(Order_Items.price * Order_Items.quantity) AS total_sales
FROM
    tbl_order_items Order_Items
JOIN
    tbl_products Products ON Order_Items.product_id = Products.product_id
GROUP BY
    Products.product_id, Products.product_name
ORDER BY
    total_sales DESC
LIMIT 10;
```

<a id="query-19"></a>
**Question No. 19:**

_Find products with less than 20 units in stock and order it using stock quantity._

```
SELECT
    Products.product_id,
    Products.product_name,
    Inventory.stock_quantity
FROM
    tbl_inventory Inventory
JOIN
    tbl_products Products ON Inventory.product_id = Products.product_id
WHERE
    Inventory.stock_quantity < 20
ORDER BY
    Inventory.stock_quantity ASC;
```

<a id="query-20"></a>
**Question No. 20:**

_Find customers who spent more than the average amount spent per customer in the last 6 months._

```
SELECT
    Customers.customer_id,
    Customers.name AS customer_name,
    SUM(Orders.total_amount) AS total_spent
FROM
    tbl_customers Customers
JOIN
    tbl_orders Orders ON Customers.customer_id = Orders.customer_id
WHERE
    Orders.order_date >= CURRENT_DATE - INTERVAL '6 months'  -- Filter orders in the last 6 months
GROUP BY
    Customers.customer_id, Customers.name
HAVING
    SUM(Orders.total_amount) > (
        SELECT
            AVG(total_spent)
        FROM (
            SELECT
                SUM(total_amount) AS total_spent
            FROM
                tbl_orders
            WHERE
                order_date >= CURRENT_DATE - INTERVAL '6 months'  -- Ensure this is also within the last 6 months
            GROUP BY
                customer_id
        ) AS customer_totals
    );
```

<br />

<a id="heading-plans-of-actions"></a>

## Plans of Actions with respect to different segments

<a id="segment-1"></a>

### 1. Campaign Effectiveness on Sales

<a id="segment-1-key-findings"></a>

#### Key Findings:

The analysis reveals several key insights related to campaign performance:

1. **Sales Contribution by Campaign**: The total revenue per campaign [(Query 10)](#query-10) and the number of orders per campaign [(Query 1)](#query-1) help us understand which campaigns are driving the most sales.
2. **Campaign Spending**: Queries related to campaign budgets and total spending [(Query 7)](#query-7) and [(Query 14)](#query-14) provide a snapshot of how budget allocations are performing compared to the actual spending.
3. **Average Order Amount per Campaign**: By identifying campaigns with an average order amount greater than $200 [(Query 17)](#query-17), we can focus on high-value campaigns.
4. **Top Campaigns per Region**: [(Query 4)](#query-4) reveals total sales by region, allowing RetailMart to compare campaign success across different locations.

<a id="segment-1-actionable-insights"></a>

#### Actionable Insights:

1. **Optimize Campaign Budgets**: Focus on campaigns that generate a high number of orders and revenue. Consider reallocating budgets from underperforming campaigns to top-performing ones.
2. **Increase Campaign Efforts in High-Performing Regions**: Prioritize regions with high total sales and orders to maximize ROI.
3. **Enhance High-Value Campaigns**: Invest in campaigns where the average order value exceeds $200 to attract more high-spending customers.

<a id="segment-2"></a>

### 2. Customer Engagement

<a id="segment-2-key-findings"></a>

#### Key Findings:

Customer-centric queries provided insight into spending patterns:

1. **High-Spending Customers**: [(Query 5)](#query-5) and [(Query 12)](#query-12) show which customers are spending the most and how much they contribute to campaign success.
2. **Average Spending by Customer**: [(Query 5)](#query-5) reveals the average amount spent per customer, while [(Query 16)](#query-16) shows customer behavior regarding frequent orders.
3. **Customers Exceeding Average Spending**: Identifying customers who spent more than the average in the last 6 months (Additional Query) highlights top-engaged customers.

<a id="segment-2-actionable-insights"></a>

#### Actionable Insights:

1. **Reward High-Spending Customers\*\***: Design loyalty programs for customers who frequently spend more than the average, to increase retention.
2. **Target Specific Campaigns to High-Spenders**: Use personalized marketing to engage customers who spend heavily on specific campaigns.
3. **Promote Low-Engagement Campaigns**: Target customers with lower average spending to encourage higher participation in key campaigns.

<a id="segment-3"></a>

### 3. Inventory Management

<a id="segment-3-key-findings"></a>

#### Key Findings:

Effective inventory tracking is critical for ensuring availability:

1. **Low Stock Products**: [(Query 19)](#query-19) helps identify products with less than 20 units in stock, ensuring RetailMart doesn’t run out of popular items.
2. **Most Popular Products by Category**: [(Query 6)](#query-6) identifies the top-performing products within each category, indicating which products need more stock.
3. **Total Quantity Sold per Product**: [(Query 15)](#query-15) and [(Query 16)](#query-16) provide a comprehensive view of total quantities sold, helping plan future inventory based on sales demand.

<a id="segment-3-actionable-insights"></a>

#### Actionable Insights:

1. **Replenish Stock for Popular Products**: Focus on restocking the most popular products and those with low stock levels to avoid missed sales opportunities.
2. **Monitor Inventory in High-Performing Regions**: Ensure that regions generating the highest sales [(Query 4)](#query-4) have enough stock to meet demand.
3. **Adjust Inventory Based on Sales Trends**: Regularly review sales data to adjust stock levels and optimize warehousing for popular products.

<a id="segment-4"></a>

### 4. Product and Sales Performance Evaluation

<a id="segment-4-key-findings"></a>

#### Key Findings:

Sales data provides a clearer understanding of product performance:

1. **Top-Selling Products**: [(Query 18)](#query-18) and [(Query 3)](#query-3) identify the best-selling products based on total sales and order counts, which can guide product marketing and inventory management.
2. **Revenue Per Product**: The total sales per product [(Query 18)](#query-18) allows RetailMart to focus on items contributing the most to revenue.
3. **Customer Preferences**: The total quantity sold and product popularity [(Query 16)](#query-16) highlight customer preferences across different categories.

<a id="segment-4-actionable-insights"></a>

#### Actionable Insights:

1. **Focus on Top-Selling Products**: Increase marketing efforts around top-performing products and ensure they are prominently featured in campaigns.
2. **Adjust Pricing for Low-Selling Products**: Reevaluate pricing strategies for products that aren’t performing well, potentially offering discounts or promotions to boost sales.
3. **Expand Stock for High Revenue Products**: Prioritize the inventory of products that contribute the most to total sales to prevent stockouts.
