USE [SuperstoreDB];

---- Bringing in CTE_sales_clean from the Data Cleaning SQL file
WITH CTE_sales_clean AS (
SELECT orderID, CustomerID, ProductID, Quantity, Price, Discount, Profit, OrderDate, ShipDate, ShippingID
FROM (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY ConcatCol ORDER BY ConcatCol) flag -- marking each duplicate with a flag > 1
	FROM (
		SELECT *, 
		CONCAT(orderID, CustomerID, ProductID, Quantity, Price, Discount, Profit, OrderDate, ShipDate, ShippingID) ConcatCol
		FROM (
			SELECT 
			orderID, 
			CustomerID,
			ProductID,
			Quantity,
			Price,
			Discount,
			Profit, -- I use profit column to calculate cost
			OrderDate,
			ShipDate,
			ShippingID
			FROM Sales
			  )t
		)t
	)t2
WHERE flag = 1 -- filtering out duplicates
) 

---- //////////////////////////////
---- 3. Data Transformation
---- //////////////////////////////

---- I added date columns including year, month and quarter

---- Profit = Revenue - Cost
---- First I calculate revenue (sales) for each order

---- CTE_sales has data on order details, dates, products
, CTE_sales_transform AS (
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
		(s.price - (s.price * s.discount)) * s.Quantity AS Revenue ---- I added a Revenue column
	FROM CTE_Sales_clean s
	LEFT JOIN Products p
	ON s.ProductID = p.ProductID
	)

-- Secondly I calculate cost for each order
, CTE_sales_transform2 AS (
	SELECT 
		OrderID, 
		OrderDate,
		Year,
		YearQuarter, 
		Quarter,
		Month,
		CustomerID,
		ProductID,
		Category,
		Subcategory,
		ProductName,
		Quantity,
		Price,
		Discount,
		Profit,
		Revenue,
		Revenue - profit AS Cost -- Cost calculation
	FROM CTE_sales_transform
	)

-- Lastly I calculate profit for each order
, CTE_sales AS (
	SELECT 
		OrderID, 
		OrderDate,
		Year,
		YearQuarter, 
		Quarter,
		Month,
		CustomerID,
		ProductID,
		Category,
		Subcategory,
		ProductName,
		Quantity,
		Price,
		Discount,
		Revenue,
		Cost,
		Revenue - Cost AS ProfitCalculated
	FROM CTE_sales_transform2
	)


---- //////////////////////////////
---- 4. Profit Analysis
---- //////////////////////////////

---- //// High-Level: Category
---- Profit by Category

--SELECT 
--Category,
--SUM(ProfitCalculated) TotalProfit
--FROM CTE_sales
--GROUP BY Category
--ORDER BY TotalProfit DESC

/* 
INSIGHT: Categories in order of total profit (highest first)
1. Office Supplies
2. Technology
3. Furniture
*/

---- //// Adding Time Dimension to Total Profit by Category

------ Profit by Category and Year
--SELECT
--Category,
--[2020], 
--[2021], 
--[2022], 
--[2023]

--FROM (

--	SELECT 
--	Category,
--	Year,
--	ProfitCalculated
--	FROM CTE_sales

--) AS SourceQuery

--PIVOT 

--(
--	SUM([ProfitCalculated])
--	FOR [Year] IN ([2020], [2021] , [2022], [2023])

--) AS PivotQuery

--ORDER BY Category

/* INSIGHT: Profit

1. Office Supplies: Increased from 2020-22. 
					Big increase 2020-21. 
					Levelled off from 2022

2. Technology: Increasing every year
				Big increase 2022-23

3. Furniture: Big drop 2020-21
			  Increasing since 2021
			  Levelling off 2022-23


Action: 
1. Need to stabilise Office Supplies to prevent a drop in its profit

NOTE: To see the chart, see [insert screenshot filename]

*/

------ Office Supplies Profit by YearQuarter
--SELECT
--Category,
--[2020 Q1], 
--[2020 Q2], 
--[2020 Q3], 
--[2020 Q4], 
--[2021 Q1], 
--[2021 Q2], 
--[2021 Q3], 
--[2021 Q4], 
--[2022 Q1], 
--[2022 Q2], 
--[2022 Q3], 
--[2022 Q4], 
--[2023 Q1],
--[2023 Q2],
--[2023 Q3],
--[2023 Q4]

--FROM (

--	SELECT 
--	Category,
--	YearQuarter,
--	ProfitCalculated
--	FROM CTE_sales

--) AS SourceQuery

--PIVOT 

--(
--	SUM([ProfitCalculated])
--	FOR [YearQuarter] IN (
--						[2020 Q1], 
--						[2020 Q2], 
--						[2020 Q3], 
--						[2020 Q4], 
--						[2021 Q1], 
--						[2021 Q2], 
--						[2021 Q3], 
--						[2021 Q4], 
--						[2022 Q1], 
--						[2022 Q2], 
--						[2022 Q3], 
--						[2022 Q4], 
--						[2023 Q1],
--						[2023 Q2],
--						[2023 Q3],
--						[2023 Q4]
--)

--) AS PivotQuery

--WHERE Category = 'Office Supplies'

/* INSIGHT: Profit 

1. Office Supplies: 

NOTE: To see the chart, see [insert screenshot filename]

*/

------ Profit (Office Supplies) by Quarter
--SELECT
--	Category,
--	[Q1], 
--	[Q2], 
--	[Q3], 
--	[Q4]

--	FROM (

--		SELECT 
--		Category,
--		Quarter,
--		ProfitCalculated
--		FROM CTE_sales

--	) AS SourceQuery

--	PIVOT 

--	(
--		SUM([ProfitCalculated])
--		FOR [Quarter] IN ([Q1], [Q2] , [Q3], [Q4])

--	) AS PivotQuery

--WHERE Category = 'Office Supplies'

/*
INSIGHT: Profit:

1. Office Supplies:

NOTE: To see the chart, see [insert screenshot filename]
*/


---- //// Mid-Level: SubCategory

-------- Profit (Office Supplies) by SubCategory
--SELECT Subcategory,
--SUM(ProfitCalculated) TotalProfit
--FROM CTE_Sales
--WHERE Category = 'Office Supplies'
--GROUP BY Subcategory
--ORDER BY TotalProfit DESC

/* 
INSIGHT: Profit 

Office Supplies: 
	Top 3 best performing Subcategories: 
							1. Appliances
							2. Art
							3. Storage

*/

SELECT *
FROM CTE_sales
WHERE Category = 'Office Supplies' AND Subcategory = 'Storage'
ORDER BY ProfitCalculated DESC

-- For Office Supplies art and appliances, seems that orders that had discount (especially 50%) had negative profit

-- Product-Level: Profit Margin = (revenue/cost) * 100
-- cost per unit = revenue per unit - profit per unit
-- To Find price per unit from sales table (Price/Quantity)



---- In this last section, I find which Technology products in the Copiers subcategory have highest Profit Margin per Unit.
---- First I calculate Cost per Unit and then I calculate Profit Margin per Unit

------ Deriving Cost Per Unit from Profit Per Unit and Price Per Unit 
--, CTE_sales_costPerUnit AS (
--SELECT s.*,
--p.Price PricePerUnit,
--p.price - (Profit/Quantity) CostPerUnit
--FROM CTE_sales s
--LEFT JOIN Products p 
--ON s.ProductID = p.ProductID)

--- Profit = Price - Cost
---- Cost = Price - Profit


---- Calculating Profit Margin Per Unit for Technology products
---- Formula: Profit Margin Per Unit = ((PricePerUnit - CostPerUnit)/ PricePerUnit) * 100
------ Improved query execution time by 13 seconds by putting RowLabel in outerquery
--SELECT TOP 10 *
--FROM (
--	SELECT *,
--	ROW_NUMBER() OVER(PARTITION BY ProductName ORDER BY ProfitMarginPerUnit DESC) RowLabel
--	FROM (
--		SELECT 
--		c.Category,
--		c.Subcategory,
--		c.productName,
--		c.quantity,
--		c.price,
--		c.discount,
--		c.profit,
--		CAST(((PricePerUnit - CostPerUnit) / PricePerUnit) * 100 AS DECIMAL(10, 1)) ProfitMarginPerUnit
--		FROM CTE_sales_costperunit c
--		WHERE Category = 'Technology'
--	)t
--)t
--WHERE RowLabel = 1 AND Subcategory = 'Copiers'
--ORDER BY ProfitMarginPerUnit DESC


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