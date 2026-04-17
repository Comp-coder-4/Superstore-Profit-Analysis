# <ins>Superstore Profit Analysis</ins>

The dataset looks at superstore sales, along with customer data and product data from 2020 to 2023.
The categories of products are Technoloy, Office Supplies and Furniture.

## Business Scenario: Which category generated the most profit?

KPI = Profit

The goal was to identify how profit varied over time on a high level (Category-level) and find the categories and subcategories with the highest profit. In the dashboard, I show the rankings of categories by profit and within each category, I rank the subcategories by profit.

Key SQL techniques used:
- CTE to clean data
- PIVOT to analyse profit by time
  
Key Power BI DAX used:
- CALCULATE() to make rankings by profit

Equation used in my analysis:
- Profit = Revenue - Cost
- Profit Margin = (Profit / Revenue) x 100


## Steps:
  1. Data Cleaning
  2. Exploratory Data Analysis
  3. Data Transformation
  4. Profit Analysis
  5. Visualisation
     
Tools used: SQL, Excel, Power BI

## Key Insights
1. Insight: Office Supplies contribution 44% of total profit
2. Insight: Office Supplies profit:
    * Increased from 2020-22.
    * Big increase from 2020 to21. 
    * Levelled off from 2022
4. Insight: Highest in Q3 and Q4. Lower during Q1 and Q2. Could try selling more high margin products in Q2 (this can encourage sales during Q2 and Q3)
  

## File Structure
- Step 1. Data Cleaning is in the Data_Cleaning.sql file
- Step 2. Exploratory Data Analysis is in the Exploratory_Data_Analysis.sql file
- Step 3. Data Transormation and Step 4. Profit per Unit Analysis are in the Analysis.sql file
- Step 5. Visualisation is in the Profit Dashboard.png file
  
- Creating_tables.sql file shows the code I used to create empty tables in SSMS

## Note
In the Sales table, 'Discount' column doesn't indicate if it's a discount on individual product items or a discount on the whole order. I explored the table and sorted by discount in descending order. Many orders had a discount greater than 50%, so it seems that these items were in clearance. In a real-world scenario, I would check with stakeholders, but for this analysis, for this reason, I assume it indicates the discount on a each individual product item.
___________
This project is a continuation of what I completed as part of Vivek P.'s "Real-World SQL Projects: Hands-On Case Studies" course and my own ideas. 
I gave the project a business problem and business context.

Data credit: Vivek P. (Real-World SQL Projects: Hands-On Case Studies Udemy Course)
