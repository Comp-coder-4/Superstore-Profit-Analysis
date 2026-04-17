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
		s.Price SalesPrice,
		s.Discount,
		s.Profit,
		p.price ProductPrice,
		CAST(ROUND((p.price - (p.price * s.discount)) * s.Quantity, 2) AS DECIMAL(10,2)) AS Revenue ---- I added a Revenue column
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
		SalesPrice,
		Discount,
		Profit,
		ProductPrice,
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
		SalesPrice,
		Discount,
		ProductPrice,
		Revenue,
		Cost,
		Profit,
		Revenue - Cost AS ProfitCalculated
	FROM CTE_sales_transform2
)

---- //////////////////////////////
---- 4. Profit Analysis
---- //////////////////////////////

---- //// High-Level: Category
---- Profit by Category
SELECT 
Category,
TotalProfit,
CONCAT(CAST(ROUND(((TotalProfit/SUM(TotalProfit) OVER()) * 100), 2) AS decimal(10, 2)), '%') PercentageContribution
FROM (
	SELECT 
	Category,
	SUM(ProfitCalculated) TotalProfit
	FROM CTE_sales
	GROUP BY Category
)t
ORDER BY TotalProfit DESC

/* 
INSIGHT: Categories in order of total profit (highest first)
1. Office Supplies: 44%
2. Technology: 38%
3. Furniture: 18%
*/

---- //// Adding Time Dimension to Total Profit by Category
------ Profit by Category and Year
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
	ProfitCalculated
	FROM CTE_sales

) AS SourceQuery

PIVOT 

(
	SUM([ProfitCalculated])
	FOR [Year] IN ([2020], [2021] , [2022], [2023])

) AS PivotQuery

ORDER BY Category

/* INSIGHT: Profit

1. Office Supplies: Increased from 2020-22. 
					Big increase 2020-21. 
					Levelled off from 2022

2. Technology: Increasing every year
				Big increase 2022-23

3. Furniture: Big drop 2020-21
			  Increasing since 2021
			  Levelling off 2022-23
------
Decision & Action: 
I decided to focus on Office Supplies and deep further into this category since
it has generated the highest profit.

Need to stabilise Office Supplies to prevent a drop in its profit.
-------

NOTE: View the chart in png file: Total Profit by Category and Year
*/

------ Office Supplies Profit by YearQuarter
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
	ProfitCalculated
	FROM CTE_sales

) AS SourceQuery

PIVOT 

(
	SUM([ProfitCalculated])
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

WHERE Category = 'Office Supplies'

/* 
NOTE: View the chart in png file: Total Profit (Office Supplies) by Year-Quarter
*/

------ Profit (Office Supplies) by Quarter
SELECT
	Category,
	[Q1], 
	[Q2], 
	[Q3], 
	[Q4]

	FROM (

		SELECT 
		Category,
		Quarter,
		ProfitCalculated
		FROM CTE_sales

	) AS SourceQuery

	PIVOT 

	(
		SUM([ProfitCalculated])
		FOR [Quarter] IN ([Q1], [Q2] , [Q3], [Q4])

	) AS PivotQuery

WHERE Category = 'Office Supplies'

/*
INSIGHT: Profit:

Office Supplies: Highest in Q3 and Q4. Lower during Q1 and Q2. Could try selling more high margin products in Q2 (this can encourage sales during Q2 and Q3)

NOTE: View the chart in png file: Total Profit (Office Supplies) by Quarter
*/


---- //// Mid-Level: SubCategory
-------- Profit (Office Supplies) by SubCategory
SELECT Subcategory,
SUM(ProfitCalculated) TotalProfit
FROM CTE_Sales
WHERE Category = 'Office Supplies'
GROUP BY Subcategory
ORDER BY TotalProfit DESC

/* 
INSIGHT: Profit 

Office Supplies: 
	Top 3 best performing Subcategories: 
							1. Appliances
							2. Art
							3. Storage
*/
