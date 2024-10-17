-- Question No. 1:
-- Select all campaigns that are currently active.

SELECT * FROM tbl_campaigns
WHERE start_date = CURRENT_DATE AND end_date = CURRENT_DATE;


-- Question No. 2:
-- Select all customers who joined after January 1, 2023.
SELECT * FROM tbl_customers WHERE join_date >'2023-01-01';


-- Question No. 3:
-- Select the total amount spent by each customer, ordered by amount in descending order.

SELECT 
	customer_id, 
	name, 
	ROUND(total_spent, 2) AS Total_Spent_In_Descending 
FROM tbl_customers 
ORDER BY Total_Spent_In_Descending DESC;


-- Question No. 4:
-- Select the products with a price greater than $50.

SELECT 
	product_id, 
	product_name, 
	price 
FROM tbl_products
WHERE price > 50;


-- Question No. 5:
-- Select the number of orders placed in the last 30 days.

SELECT COUNT(*) AS orders_count
FROM tbl_orders
WHERE order_date > CURRENT_DATE - 30;


-- Question No. 6:
-- Order the products by price in ascending order and limit the results to the top 5 most affordable products.

SELECT 
	product_id, 
	product_name, 
	price 
FROM tbl_products 
ORDER BY price ASC 
LIMIT 5;


-- Question No. 7:
-- Select the campaign names and their budgets.

SELECT DISTINCT 
	campaign_name, 
	budget
FROM tbl_campaigns;


-- Question No. 8:
-- Select the total quantity sold for each product, ordered by quantity sold in descending order.

SELECT 
	product_id, 
	SUM(quantity) AS total_quantity_sold 
FROM tbl_order_items
GROUP BY product_id 
ORDER BY total_quantity_sold DESC;


-- Question No. 9:
-- Select the details of orders that have a total amount greater than $100.

SELECT 
	order_id, 
	customer_id, 
	total_amount, 
	order_date
FROM tbl_orders
WHERE total_amount > 100;


-- Question No. 10:
-- Find the total number of customers who have made at least one purchase.
SELECT COUNT(*) as customer_count 
FROM tbl_customers
JOIN tbl_orders
ON tbl_customers.customer_id = tbl_orders.customer_id;


-- Question No. 11:
-- Select the top 3 campaigns with the highest budgets.
SELECT 
	campaign_id, 
	campaign_name, 
	budget 
FROM tbl_campaigns
ORDER BY budget DESC
LIMIT 3;


-- Question No. 12:
-- Select the top 5 customers with the highest total amount spent.
SELECT 
	customer_id, 
	name, 
	total_spent 
FROM tbl_customers
ORDER BY total_spent DESC
LIMIT 5;



