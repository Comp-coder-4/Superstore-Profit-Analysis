USE [SuperstoreDB];
---- //////////////////////////////
---- 1. Data Cleaning
---- //////////////////////////////
---- The query below shows that the Sales table has duplicate rows for 1 order (orderID = AZ-2011-6674300)
SELECT *
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ConcatCol ORDER BY ConcatCol) flag -- marking each duplicate with a flag > 1
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
		(price) - (price * discount) Sales,
		CONCAT(orderID, CustomerID, ProductID, Quantity, Price, Discount, Profit, OrderDate, ShipDate, ShippingID) ConcatCol
		FROM Sales)
		t)t2
		WHERE OrderID = 'AZ-2011-6674300'

/*
---- I made a CTE that removes duplicate rows from Sales table and adds a sales column

---- Steps I took:
---- Step 1) Create a column called 'ConcatCol'. For each row, this column concatenates 
	the values from all column in the same row. 
	If there are duplicates in the ConcatCol column, that means there are duplicate rows.
---- Step 2) Create a column called 'flag'. For the first occurence of each value in the 
	ConcatCol column, the flag column will assign it the number 1. 
	If there are duplicate values in the ConcatCol column, the flag will assign
	each duplicate with a value	greater than 1
---- Step 3) Filter for unique rows. To do this, I use the filter 'WHERE flag = 1'
*/

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

---- Check for NULL values
---- This query shows there are No NULLS
SELECT * FROM CTE_sales_clean
WHERE orderID IS NULL 
	OR CustomerID IS NULL
	OR ProductID IS NULL
	OR Quantity IS NULL
	OR Price IS NULL
	OR Discount IS NULL
	OR Profit IS NULL
	OR OrderDate IS NULL
	OR ShipDate IS NULL
	OR ShippingID IS NULL
	OR Sales IS NULL

----- 
/* Problem with dataset: 
In Sales table:
1. Is price column showing price of mulitple products or for a single product?
2. Is the profit column showing the profit from the multiple products or profit per unit product? */

---- Order the table from highest profit
---- In row 2, it's unlikely that 1 Nokia  

---- This query shows that the price of 1 Nokia Smart Phone, Full Size is 636
SELECT *
FROM Products
WHERE ProductName LIKE 'Nokia smart phone, full size'

---- In the sales table in the following query, looking at row 2, the price of 9 Nokia Smart Phones (Full size) is 5724
---- So in the sales table, Price column = Price per product * Quantity
---- It's more reasonable to assume that 9 Nokia phones generated a profit of £2461 instead of assuming each Nokia phone generated a profit of £2461. 
---- Likewise in row 28, it's likely that the £1050 profit came from 5 bookcases and not from one bookcase 
SELECT 
s.OrderID, 
s.OrderDate,
s.CustomerID,
s.ProductID,
p.Category,
p.Subcategory,
p.ProductName,
s.Quantity,
s.Price,
s.Discount,
s.Profit
FROM CTE_Sales_clean s
LEFT JOIN Products p
ON s.ProductID = p.ProductID
ORDER BY Profit DESC 