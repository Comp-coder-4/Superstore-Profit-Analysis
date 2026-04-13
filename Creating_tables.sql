---- Here is the script I used to create the Customer, Product, Shipping, TargetSales and Sales tables, including primary keys and foreign keys

---- Handled foreign key dependeny issues by ensuring that the Sales table (which has foreign keys referring to primary keys of the other tables) was created last

---- Creating Customers table
CREATE TABLE Customer (
ID VARCHAR(10) PRIMARY KEY,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Email VARCHAR(100),
City VARCHAR(100),
State VARCHAR(100),
Country	VARCHAR(100),
Region VARCHAR(50)
)

---- Creating Products table
CREATE TABLE Products (
ProductID VARCHAR(20) PRIMARY KEY,
Category VARCHAR(50),
Subcategory VARCHAR(50),
ProductName	VARCHAR(200),
Manufacturer VARCHAR(100),
Price DECIMAL(12,2)
)

---- Creating Shipping table
CREATE TABLE Shipping (
ShippingID varchar(10) PRIMARY KEY,
ShipMode varchar(50),
ShippingCost DECIMAL(10,2),
Carrier	VARCHAR(50)
)

-- Creating Target Sales table
CREATE TABLE TargetSales (
Category VARCHAR(50),
[2020_Sales] INT,
[2021_Sales] INT,
[2022_Sales] INT,
[2023_Sales] INT
)

------ Creating Sales Table
CREATE TABLE Sales (
OrderID	varchar(20),
CustomerID varchar(10),
ProductID varchar(20),
Quantity INT,
Price DECIMAL(12,2),
Discount DECIMAL(5,2),
Profit DECIMAL(12,2),
OrderDate DATE,
ShipDate DATE,
ShippingID varchar(10),
CONSTRAINT fkCustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
CONSTRAINT fkProductID FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
CONSTRAINT fkShippingID FOREIGN KEY (ShippingID) REFERENCES Shipping(ShippingID)
)