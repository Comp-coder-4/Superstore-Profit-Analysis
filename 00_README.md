# Superstore Profit Analysis

The dataset looks at superstore sales, along with customer data and product data from 2020 to 2023.
The categories of products are Technoloy, Office Supplies and Furniture.

## Business Scenario: Which category generated the most profit?

KPI = Profit

The goal was to identify how profit varied over time on a high level (Category-level), find the categories and subcategories with the highest profit

Equations used in my analysis:
- Profit = Revenue - Cost

## Steps:
  1. Data Cleaning
  2. Exploratory Data Analysis
  3. Data Transformation
  4. Profit Analysis
  5. Visualisation
     
Tools used: SQL, Excel, Power BI

## Key Insights & Recommendations
- Insight: 
  
Recommendation: 

- Insight: 
Recommendation: 

## File Structure
- Step 1. Data Cleaning is in the Data_Cleaning.sql file
- Step 2. Exploratory Data Analysis is in the Exploratory_Data_Analysis.sql file
- Step 3. Data Transormation and Step 4. Profit per Unit Analysis are in the Analysis.sql file
- Step 5. Visualisation is in the Power BI Dashboard.png file
  
- Creating_tables.sql file shows the code I used to create empty tables in SSMS

## Note
In the Sales table, 'Discount' column doesn't indicate if it's a discount on individual product items or a discount on the whole order. I explored the table and sorted by discount in descending order. Many orders had a discount greater than 50%, so it seems that these items were in clearance. In a real-world scenario, I would check with stakeholders, but for this analysis, for this reason, I assume it indicates the discount on a each individual product item.
___________
This project is a continuation of what I completed as part of Vivek P.'s "Real-World SQL Projects: Hands-On Case Studies" course and my own ideas. 
I gave the project a business problem and business context.

Data credit: Vivek P. (Real-World SQL Projects: Hands-On Case Studies Udemy Course)
