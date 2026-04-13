USE [SuperstoreDB];

---- //////////////////////////////
---- 2. Exploratory Data Analysis
---- //////////////////////////////

---- Bringing in CTE_sales_clean from the Data Cleaning SQL file
WITH CTE_sales_clean AS (
SELECT orderID, CustomerID, ProductID, Quantity, Price, Discount, Profit, OrderDate, ShipDate, ShippingID, Sales
FROM (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY ConcatCol ORDER BY ConcatCol) flag -- marking each duplicate with a flag > 1
	FROM (
		SELECT *, 
		CONCAT(orderID, CustomerID, ProductID, Quantity, Price, Discount, Profit, OrderDate, ShipDate, ShippingID, Sales) ConcatCol
		FROM (
			SELECT 
			orderID, 
			CustomerID,
			ProductID,
			Quantity,
			Price,
			Discount,
			Profit,
			OrderDate,
			ShipDate,
			ShippingID,
			(price) - (price * discount) Sales ---- I added a Sales column
			FROM Sales
			  )t
		)t
	)t2
WHERE flag = 1 -- filtering out duplicates
) 

---- //////////////////////////////
---- Database Exploration
---- //////////////////////////////
SELECT *
FROM INFORMATION_SCHEMA.TABLES

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS


---- //////////////////////////////
---- Date Exploration
---- //////////////////////////////

/* date columns (sales table)
order date
ship date */

-- latest and oldest order & number of years orders have been made
SELECT 
MIN(Orderdate) oldest_order, 
MAX(Orderdate) latest_order,
DATEDIFF(year, MIN(Orderdate), MAX(Orderdate)) years_of_orders
FROM CTE_sales_clean


---- //////////////////////////////
---- Dimension Exploration
---- //////////////////////////////

-- Look at unique values in dimensions

-- Customers
-- dimensions: city, state, country, region
SELECT DISTINCT region
FROM Customer

-- We are looking at countries in Europe
SELECT DISTINCT country
FROM Customer

-- Product
-- dimensions: category, subcategory
-- 3 categories of products: Office supplies, furniture and technology
SELECT DISTINCT Category
FROM Products

-- Categories and their Subcategories
SELECT category, subcategory
FROM (
SELECT category, SubCategory, ROW_NUMBER() OVER(PARTITION BY Category, subcategory ORDER BY Subcategory) flag
FROM products)t
WHERE flag = 1
order by Category, SubCategory

-- Shipping
-- There are 4 ship modes
SELECT COUNT(DISTINCT ShipMode) shipmodes
FROM shipping


---- //////////////////////////////
---- Magnitude Analysis
---- //////////////////////////////

---- Total customers by country
SELECT c.country,
COUNT(DISTINCT s.customerID) total_customers
FROM CTE_sales_clean s
LEFT JOIN Customer c
ON s.CustomerID = c.ID
GROUP BY c.country
ORDER BY total_customers DESC

---- Total products by category
SELECT Category,
COUNT(ProductID) total_products
FROM Products
GROUP BY Category
ORDER BY total_products DESC

---- Total profit for each category
SELECT category, SUM(profit) total_profit
FROM (
	SELECT 
	s.ProductID, 
	p.Category,
	s.profit
	FROM CTE_sales_clean s
	LEFT JOIN Products p
	ON s.ProductID = p.ProductID
)t
GROUP BY Category
ORDER BY total_profit DESC

---- Total profit by customer
SELECT customerID, customer_name, SUM(profit) total_profit
FROM (
	SELECT 
	s.customerID, 
	CONCAT(c.firstName, ' ', c.lastName) customer_name,
	s.profit
	FROM CTE_sales_clean s
	LEFT JOIN Customer c
	ON s.customerID = c.ID
)t
GROUP BY customerID, customer_name
ORDER BY total_profit DESC

---- Distribution of items sold across countries (quantity by country)
SELECT
Country,
SUM(Quantity) total_items
FROM (
	SELECT s.Quantity,
	c.Country
	FROM CTE_sales_clean s
	LEFT JOIN Customer c
	ON s.CustomerID = c.ID
	)t
GROUP BY country
ORDER BY total_items DESC


---- //////////////////////////////
---- Measures Exploration
---- //////////////////////////////

-- Measures Exploration
-- Calculate high level aggregations (key metrics)

-- Making a report showing all key metrics of the business

SELECT 'total sales' Measure_Name, SUM(sales) Measure_Value 
FROM CTE_sales_clean

UNION ALL

SELECT 'total orders', COUNT(DISTINCT orderID)
FROM CTE_sales_clean

UNION ALL

SELECT 'total customers', count(distinct id)
FROM customer

UNION ALL

SELECT 'total products', COUNT(DISTINCT ProductID)
FROM Products

UNION ALL

SELECT 'total profit', SUM(Profit)
FROM CTE_sales_clean


---- //////////////////////////////
----- Ranking Analysis
---- //////////////////////////////

---- Top 5 ranking products by profit
SELECT TOP 5 s.ProductID,
p.productName,
p.Category,
p.SubCategory,
s.profit,
DENSE_RANK() OVER(ORDER BY profit DESC) rank
FROM CTE_sales_clean s
LEFT JOIN Products p 
ON s.ProductID = p.ProductID

---- Lowest 5 ranking products by profit
SELECT TOP 5 s.ProductID,
p.productName,
p.Category,
p.SubCategory,
s.profit,
DENSE_RANK() OVER(ORDER BY profit ASC) rank
FROM CTE_sales_clean s
LEFT JOIN Products p 
ON s.ProductID = p.ProductID