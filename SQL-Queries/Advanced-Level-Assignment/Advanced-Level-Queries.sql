-- Question No. 1:
-- Select the campaigns with the highest and lowest budgets.
CREATE INDEX idx_campaigns_budget ON tbl_campaigns(budget);

SELECT campaign_name, budget FROM tbl_campaigns
ORDER BY budget DESC LIMIT 1;

SELECT campaign_name, budget FROM tbl_campaigns
ORDER BY budget ASC LIMIT 1;


-- Question No. 2:
-- Find the average price of products across all categories.

CREATE INDEX idx_products_category ON tbl_products(category);

SELECT category, AVG(price) AS avg_price
FROM tbl_products
GROUP BY category;

-- Question No. 3:
-- Rank products based on their total sales within each category.

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


-- Question No. 4:
-- Create a CTE to calculate the total revenue and average order amount for each campaign.

CREATE INDEX idx_orders_campaign_id ON tbl_orders(campaign_id);

WITH campaign_revenue AS (
    SELECT campaign_id, SUM(total_amount) AS total_revenue, AVG(total_amount) AS avg_order_amount
    FROM tbl_orders
    GROUP BY campaign_id
)
SELECT campaign_id, total_revenue, avg_order_amount
FROM campaign_revenue;


-- Question No. 5:
-- Handle any missing stock quantities and provide a default value of 0 for products with no recorded inventory.

CREATE INDEX idx_inventory_product_id ON tbl_inventory(product_id);

SELECT Product.product_name, COALESCE(Inventory.stock_quantity, 0) AS stock_quantity
FROM tbl_products Product
LEFT JOIN tbl_inventory Inventory ON Product.product_id = Inventory.product_id;


-- Question No. 6:
-- Analyse the total quantity and revenue generated from each product by customer.

CREATE INDEX idx_orders_customer_id ON tbl_orders(customer_id);

SELECT Customers.name, Products.product_name, 
       SUM(Order_Items.quantity) AS total_quantity,
       SUM(Order_Items.quantity * Order_Items.price) AS total_revenue
FROM tbl_order_items Order_Items
JOIN tbl_products Products ON Order_Items.product_id = Products.product_id
JOIN tbl_orders Orders ON Order_Items.order_id = Orders.order_id
JOIN tbl_customers Customers ON Orders.customer_id = Customers.customer_id
GROUP BY Customers.name, Products.product_name;


-- Question No. 7
-- Find campaigns that have a higher average order amount than the overall average.

WITH avg_order_amount AS (
    SELECT AVG(total_amount) AS overall_avg
    FROM tbl_orders
)
SELECT Campaigns.campaign_name, AVG(Orders.total_amount) AS campaign_avg
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Campaigns.campaign_name
HAVING AVG(Orders.total_amount) > (SELECT overall_avg FROM avg_order_amount);


-- Question No. 8:
-- Analyse the rolling average of sales per campaign over the last 3 months.

-- composite index
CREATE INDEX idx_orders_campaign_id_order_date ON tbl_orders(campaign_id, order_date);

SELECT campaign_id, order_date, 
       AVG(total_amount) OVER (PARTITION BY campaign_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM tbl_orders;


-- Question No. 9:
-- Calculate the growth rate of sales for each campaign over time and rank them accordingly.

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


-- Question No. 10:
-- Use CTEs and Window Functions to find the top 5 customers who have consistently spent above the 75th percentile of customer spending.

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



-- Question No. 11:
-- Use Advanced Sub-Queries to find the correlation between campaign budgets and total revenue generated.

SELECT Campaigns.budget, SUM(Orders.total_amount) AS total_revenue
FROM tbl_campaigns Campaigns
JOIN tbl_orders Orders ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY Campaigns.budget;


-- Question No. 12:
-- Partition the sales data to compare the performance of different regions and identify any anomalies.

CREATE INDEX idx_campaigns_region ON tbl_campaigns(region);

SELECT Campaigns.region, SUM(Orders.total_amount) AS total_sales,
       RANK() OVER (PARTITION BY Campaigns.region ORDER BY SUM(Orders.total_amount) DESC) AS region_rank
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Campaigns.region;


-- Question No. 13:
-- Analyse the impact of product categories on campaign success.

SELECT Product.category, Campaigns.campaign_name, 
       SUM(Order_Items.quantity * Order_Items.price) AS total_revenue
FROM tbl_order_items Order_Items
JOIN tbl_products Product ON Order_Items.product_id = Product.product_id
JOIN tbl_orders Orders ON Order_Items.order_id = Orders.order_id
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id
GROUP BY Product.category, Campaigns.campaign_name;


-- Ques4ion No. 14:
-- Compute the moving average of sales per region and analyze trends.

-- Query to calculate the moving average of sales per region
SELECT Campaigns.region, Orders.order_date, 
       AVG(Orders.total_amount) OVER (PARTITION BY Campaigns.region ORDER BY Orders.order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM tbl_orders Orders
JOIN tbl_campaigns Campaigns ON Orders.campaign_id = Campaigns.campaign_id;


-- Question No. 15:
-- Evaluate the effectiveness of campaigns by comparing the pre-campaign and post-campaign average sales.

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

































































