USE [SuperstoreDB];

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
---- 3. Data Transformation
---- //////////////////////////////

---- I created a CTE called 'CTE_Sales'.
---- In this CTE I added date columns including year, month and quarter
---- The CTE has data on order details, dates, products and profit
, CTE_sales AS (
SELECT 
s.OrderID, 
s.OrderDate,
YEAR(s.orderdate) Year,
CONCAT(YEAR(s.orderdate), ' ', CONCAT('Q', DATENAME(QUARTER, s.OrderDate))) YearQuarter,
CONCAT('Q', DATENAME(QUARTER, s.OrderDate)) Quarter,
DATENAME(MONTH, s.OrderDate) Month,
s.CustomerID,
s.ProductID,
p.Category,
p.Subcategory,
p.ProductName,
s.Quantity,
s.Price,
s.Discount,
s.Profit,
Sales
FROM CTE_Sales_clean s
LEFT JOIN Products p
ON s.ProductID = p.ProductID
)


---- //////////////////////////////
---- 4. Profit per Unit Analysis
---- //////////////////////////////

---- //// High-Level: Category

---- Profit Per Unit by Category
SELECT
Category,
TotalProfit,
TotalQuantity,
TotalProfit/TotalQuantity ProfitPerUnit
FROM (
	SELECT 
	Category,
	SUM(Profit) TotalProfit,
	SUM(Quantity) TotalQuantity
	FROM CTE_sales
	GROUP BY Category)t
ORDER BY ProfitPerUnit DESC

/* 
INSIGHT: Profit Per Unit

Technology category has highest 
Office Supplies has lowest

*/

---- //// Adding Time Dimension to Category

---- Profit Per Unit by Category and Year
SELECT
Category,
[2020], 
[2021], 
[2022], 
[2023]

FROM (

	SELECT 
	Category,
	Year,
	CAST(ROUND(SUM(Profit)/SUM(Quantity), 1) AS DECIMAL(10, 1)) ProfitPerUnit
	FROM CTE_sales
	GROUP BY Category, Year

) AS SourceQuery

PIVOT 

(
	MAX([ProfitPerUnit])
	FOR [Year] IN ([2020], [2021] , [2022], [2023])

) AS PivotQuery

ORDER BY Category

/* INSIGHT: Profit Per Unit

Technology: Gradually decreasing every year

Furniture: Big drop from 2020 to 2021 (Approx. halved)
		   Highest in 2020
		   Lowest in 2021

Office Supplies: More or less stable over years
				 Peaked in 2022

RECOMMENDATION: Focus on stabilising Technology category profits as this is where Profit per Unit is highest

*/

---- Technology Profit Per Unit by YearQuarter
SELECT
Category,
[2020 Q1], 
[2020 Q2], 
[2020 Q3], 
[2020 Q4], 
[2021 Q1], 
[2021 Q2], 
[2021 Q3], 
[2021 Q4], 
[2022 Q1], 
[2022 Q2], 
[2022 Q3], 
[2022 Q4], 
[2023 Q1],
[2023 Q2],
[2023 Q3],
[2023 Q4]

FROM (

	SELECT 
	Category,
	YearQuarter,
	CAST(ROUND(SUM(Profit)/SUM(Quantity), 1) AS DECIMAL(10, 1)) ProfitPerUnit
	FROM CTE_sales
	GROUP BY Category, YearQuarter

) AS SourceQuery

PIVOT 

(
	MAX([ProfitPerUnit])
	FOR [YearQuarter] IN (
						[2020 Q1], 
						[2020 Q2], 
						[2020 Q3], 
						[2020 Q4], 
						[2021 Q1], 
						[2021 Q2], 
						[2021 Q3], 
						[2021 Q4], 
						[2022 Q1], 
						[2022 Q2], 
						[2022 Q3], 
						[2022 Q4], 
						[2023 Q1],
						[2023 Q2],
						[2023 Q3],
						[2023 Q4]
)

) AS PivotQuery

WHERE Category = 'Technology'

/* INSIGHT: Profit Per Unit

Technology: Highest in Q2
		    Lowest in Q1

*/

/* NOTE
To see Profit per Unit by Category (for all categories) and Year-Quarter, please see "Profit per Unit By Category and Year-Quarter.png file"

To see Technology Profit per Unit by Quarter, please see "Technology Profit per Unit By Quarter.png file"
*/


---- //// Mid-Level: SubCategory

------ Profit Per Unit by SubCategory
SELECT
Category,
SubCategory,
TotalProfit/TotalQuantity ProfitPerUnit
FROM (
	SELECT 
	Category,
	SubCategory,
	SUM(Profit) TotalProfit,
	SUM(Quantity) TotalQuantity
	FROM CTE_sales
	GROUP BY Category, SubCategory)t
WHERE Category = 'Technology'
ORDER BY Category, ProfitPerUnit DESC

/* 
INSIGHT: Profit Per Unit

Technology: Best performing subcategory = Copiers
		    Worst performing subcategory = Machines
*/



---- In this last section, I find which Technology products in the Copiers subcategory have highest Profit Margin per Unit.
---- First I calculate Cost per Unit and then I calculate Profit Margin per Unit

---- Deriving Cost Per Unit from Profit Per Unit and Price Per Unit 
, CTE_sales_costPerUnit AS (
SELECT s.*,
p.Price PricePerUnit,
p.price - (Profit/Quantity) CostPerUnit
FROM CTE_sales s
LEFT JOIN Products p 
ON s.ProductID = p.ProductID)

--- Profit = Price - Cost
---- Cost = Price - Profit


---- Calculating Profit Margin Per Unit for Technology products
---- Formula: Profit Margin Per Unit = ((PricePerUnit - CostPerUnit)/ PricePerUnit) * 100
---- Improved query execution time by 13 seconds by putting RowLabel in outerquery
SELECT TOP 10 *
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ProductName ORDER BY ProfitMarginPerUnit DESC) RowLabel
	FROM (
		SELECT 
		c.Category,
		c.Subcategory,
		c.productName,
		c.quantity,
		c.price,
		c.discount,
		c.profit,
		CAST(((PricePerUnit - CostPerUnit) / PricePerUnit) * 100 AS DECIMAL(10, 1)) ProfitMarginPerUnit
		FROM CTE_sales_costperunit c
		WHERE Category = 'Technology'
	)t
)t
WHERE RowLabel = 1 AND Subcategory = 'Copiers'
ORDER BY ProfitMarginPerUnit DESC


/* INSIGHT:
TOP 5 Technology Copier products with the highest Profit Margin Per Unit:

1. Hewlett Copy Machine, Color
2. HP Fax and Copier, Digital
3. Sharp Copy Machine, High-Speed
4. Sharp Wireless Fax, Color
5. Canon Ink, High Speed

RECOMMENDATION:
Focus marketing efforts to promote these top 5 technology copier products over low margin items
*/