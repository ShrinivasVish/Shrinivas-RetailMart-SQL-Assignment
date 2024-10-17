-- Question No. 1:
-- Select the number of orders per campaign and order by the number of orders in descending order.

SELECT COUNT(*) AS orders_count 
FROM 
	tbl_orders
GROUP BY 
	campaign_id
ORDER BY 
	orders_count DESC;



-- Question No. 2:
-- Find the average order amount for each campaign.

SELECT 
	campaign_id,
	ROUND(AVG(total_amount), 2) AS average_order_amount 
FROM 
	tbl_orders
GROUP BY 
	campaign_id;



-- Question No. 3:
-- Select the products that have been ordered more than 100 times in total.

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




-- Question No. 4:
-- Find the total sales for each region and order by sales in descending order.

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




-- Question No. 5:
-- Select the average amount spent per customer and order by this average in descending order.

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



-- Question No. 6:
-- Select the most popular product in each category.

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



-- Question No. 7:
-- Find the total budget of all campaigns that have ended.

SELECT 
	SUM(budget) AS total_budget
FROM 
	tbl_campaigns
WHERE 
	end_date < CURRENT_DATE;




-- Question No. 8:
-- Get order details along with campaign names.

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



-- Question No. 9:
-- Get product details for each order item.

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



-- Question No. 10:
-- Aggregate the total revenue per campaign.

SELECT 
    Campaigns.campaign_id,
    Campaigns.campaign_name,
    SUM(Orders.total_amount) AS total_revenue
FROM tbl_campaigns Campaigns LEFT JOIN tbl_orders Orders 
	ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY 
    Campaigns.campaign_id, Campaigns.campaign_name;



-- Question No. 11:
-- Find the total number of orders placed per region.

SELECT 
    Campaigns.region,
    COUNT(Orders.order_id) AS total_orders
FROM 
    tbl_campaigns Campaigns
LEFT JOIN tbl_orders Orders ON Campaigns.campaign_id = Orders.campaign_id
GROUP BY Campaigns.region;




-- Question No. 12:
-- Find the total amount spent by each customer on each campaign.

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



-- Question No. 13:
-- Use Aggregate Functions to find the average budget of all campaigns and group by region.

SELECT 
    region,
    ROUND(AVG(budget), 2) AS average_budget
FROM 
    tbl_campaigns
GROUP BY 
    region;



-- Question No. 14:
-- Filter campaigns with a total spending greater than their budget using a sub-query.

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



-- Question No. 15:
-- Calculate the total quantity sold and average price per product.

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



-- Question No. 16:
-- Aggregate the total quantity sold per product.

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



-- Question No. 17:
-- Find campaigns with an average order amount greater than $200.

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



-- Question No. 18:
-- Find the top 10 products with the highest total sales amount and order by sales in descending order.

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



-- Question No. 19:
-- Find products with less than 20 units in stock and order it using stock quantity.

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



-- Question No. 20:
-- Find customers who spent more than the average amount spent per customer in the last 6 months.

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
