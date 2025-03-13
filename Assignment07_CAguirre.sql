--*************************************************************************--
-- Title: Assignment07
-- Author: CAguirre
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,CAguirre,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_CAguirre')
	 Begin 
	  Alter Database [Assignment07DB_CAguirre] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_CAguirre;
	 End
	Create Database Assignment07DB_CAguirre;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_CAguirre;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
-- Okay, let's look at our products view! We need ProductName and we need UnitPrice displayed as USD.
Select * From vProducts;
-- We're just looking for a table result that matches our result set in the homework.
--------------------------------------------------------------------------------------------------
-- Let's start by selecting ProductName from our view.
Select ProductName, 
-- Next we need to format our UnitPrice column as a currency and specify that we need a 
-- symbol denoting currency. So, we use "format", stick in our column we're referencing, 
-- specify the need for the symbol ('C') and the locale ('en-US' = USD).
	Format (UnitPrice, 'C', 'en-us') as UnitPrice 
-- We're referencing the view, not the table, so From vProducts
From vProducts
-- and to match the result set, we order by product name so things pop up alphabetically.
Order by ProductName;
go
--------------------------------------------------------------------------------------------------
-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- Let's throw in our views for easy reference.
Select * From vCategories;
go
Select * From vProducts;
go
--------------------------------------------------------------------------------------------------
-- What columns do we need? CategoryName, ProductName, UnitPrice! Since this is 2 different tables,
-- there will need to be a join in the code that we write. We'll also be including an Order By clause.
-- I'll do the join on the CategoryID. Let's throw in our select statement with our columns that we want
-- displayed in the result set.

-- adding our join, setting our aliases, joining on the column CategoryID and
-- ordering by the categories specified in the question.

--Select c.CategoryName, p.ProductName, p.UnitPrice
--	From vProducts as p
--	Join vCategories as c 
--		On p.CategoryID = c.CategoryID
--	Order by c.CategoryID, p.ProductName
--go

-- This gets us really close to our result set but I need to reformat the pricing to reflect the currency
-- again! Let's adjust it.
Select c.CategoryName, p.ProductName, 
	Format (p.UnitPrice, 'C', 'en-us') as UnitPrice 
		From vProducts as p
		Join vCategories as c 
			On p.CategoryID = c.CategoryID
	Order by c.CategoryID, p.ProductName
	go
-- There's the desired result set!
--------------------------------------------------------------------------------------------------
-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
-- Slapping my views here for easy reference.
Select * From vProducts;
go
Select * From vInventories;
go
--------------------------------------------------------------------------------------------------
-- This requires another join on two tables and formatting for the date! 
-- We want the columns: ProductName, InventoryDate, and Count.
--Select p.ProductName, i.InventoryDate, i.[Count]
--	From vProducts as p
--	Join vInventories as i 
--		On p.ProductId = i.ProductId
--Order by p.ProductName, i.inventoryDate;
--go
--------------------------------------------------------------------------------------------------
-- This code gets us close but doesn't format the date in the desired way! How to fix, I wonder?
-- I looked it up in the notes for the module and it'll be very similar to the currency but with date
-- specifics. It should look something like this: Format(i.InventoryDate, 'MMMM, yyyy') as InventoryDate
-- Let's insert into the above code and see if it works.
Select p.ProductName,
	Format(i.InventoryDate, 'MMMM, yyyy') as InventoryDate,
	i.[Count] as InventoryCount
From vProducts as p
	Join vInventories as i 
		On p.ProductId = i.ProductId
Order by p.ProductName, i.InventoryDate;
go
--------------------------------------------------------------------------------------------------
-- REGARDING Question 3 - 
-- I had a really annoying thing happen here that I want to write out so I can reference later.
-- I had it ordered by the InventoryDate column instead of the original i.InventoryDate column
-- and for some reason it just wouldn't order correctly! So I swapped the column and it fixed it. 
--------------------------------------------------------------------------------------------------
-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
--------------------------------------------------------------------------------------------------
-- NOTE TO SELF DON'T FORGET TOP 10000000 OR WHATEVER SO IT WORKS! Let's SchemaBind it for fun.
-- Or practicality I guess.
--------------------------------------------------------------------------------------------------
Create view vProductInventories with SchemaBinding
	As
		Select Top 1000000
			p.ProductName, 
			Format(i.InventoryDate, 'MMMM, yyyy') as InventoryDate,
			i.[Count] as InventoryCount
-- I also forgot about the two part naming convention here and got an error.
-- Adding a note for my own future reference.
		From dbo.vProducts as p
		Join dbo.vInventories as i 
			On p.ProductId = i.ProductID
	Order by p.ProductName, i.InventoryDate;
go
-- Check that it works: AND IT DOES!
Select * From vProductInventories;
go
--------------------------------------------------------------------------------------------------
-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
-- Referencing Category table and Inventory views.
-- Views for quick review: 
Select * From vCategories;
go
Select * From vInventories;
go
Select * From vProducts;
go
-- Referencing CategoryName, InventoryDate, and creating a new column that gives total inventory count
-- by Category. To do this we need a table that shares columns with both of these bad boys.
-- We'll also need to reference vProducts. So how do we make this complicated view?

-- Selecting our desired columns and formatting them to be appropriate! Let's do the easiest column first.
--Select c.CategoryName, 
---- Formatting for inventory date.
--	Format(i.InventoryDate, 'MMMM, yyyy') as InventoryDate,
---- Throwing in the function for summarizing count by category - literally just summing our counts I think?
--	[InventoryCountByCategory] = Sum(i.[Count]) 
---- Doing our complicated join on the columns that are shared across tables.
--From vCategories as c
--	Join vProducts as p
--		On c.CategoryID = p.CategoryID
--	Join vInventories as i
--		On p.ProductID = i.ProductID
--Group by c.CategoryName, InventoryDate
--Order By c.CategoryName, i.InventoryDate;
--go
-- THIS MADE SOMETHING THAT LOOKS LIKE THE RESULT SET! 
-- LET'S MAKE THE VIEW NOW!
Create view vCategoryInventories with SchemaBinding
	As
Select Top 100000
	c.CategoryName, 
	Format(i.InventoryDate, 'MMMM, yyyy') as InventoryDate,
	[InventoryCountByCategory] = Sum(i.[Count]) 
-- Don't forget the two part name for the views below to make the code work!
From dbo.vCategories as c
	Join dbo.vProducts as p
		On c.CategoryID = p.CategoryID
	Join dbo.vInventories as i
		On p.ProductID = i.ProductID
Group by c.CategoryName, InventoryDate
Order By c.CategoryName, i.InventoryDate;
go
-- Check that it works: 
Select * From vCategoryInventories;
go
-- She works!
--------------------------------------------------------------------------------------------------
-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
-- So.. this is complicated. Let's build out the code that we already know works.

Create View vProductInventoriesWithPreviousMonthCounts with SchemaBinding  
	As
		Select TOP 1000000 
			vPI.ProductName, 
			vPI.InventoryDate,
			Sum(vPI.InventoryCount) as InventoryCount,
		-- Creating our new column and using our old logic that worked for previous columns.
			[PreviousMonthCount] = 
		-- IsNull sets value to 0 f no previous month's data exists and gets rid of null values.
				IsNull(Lag(Sum(vPI.InventoryCount),1,0) 
		-- 1 looks at a previous row, 0 is replacement for null value. Partitioning because we
		-- want to look at each product separately.
				Over(Partition by ProductName 
		-- ordering by month and using InventoryDate column for reference.
			Order By Month(vPI.InventoryDate)),0)
		From  dbo.vProductInventories as vPI
	Group by vPI.InventoryDate, vPI.ProductName;
go
--------------------------------------------------------------------------------------------------
-- Lag template w/ definitions for my reference: 

--SELECT 
--    column1, -- Main column (Product, Employee)
--    column2, -- Date/time column (SaleDate, InventoryDate)
--    column3, -- Column I want to track (SalesAmount, InventoryCount)

    ------ LAG OVERVIEW

--    LAG(column3, offset, default_value) 
	------ Column3 - column I wanna track
	------	Offset: Specifies how many rows back to look (default 1).
	------ default_value: value to return if there is no previous row 
	------ the default is NULL so need to specify 0 in my code.

--        OVER (PARTITION BY partition_column ORDER BY order_column) AS PreviousValue
	------ Partition defines how data will be split up, partition column is ProductName for this.
	------ Over defines how LAG() operates in relation to data.
	------ Ordering by InventoryDate per question stipulations.

--FROM table_name;
--------------------------********************************-----------------------------------------
-- Lag code should look something like this - adding IsNull to Lag for easier time with the 0 values.
-- [PreviousMonthCount] = 
	--IsNull(
	---- LAG STATEMENT- summarizing inventory count, looking back 1 row, using 0 as a replacement for null
	---- value. 
	---- Partitioning by ProductName and ordering by Month which references InventoryDate.
	-- Lag(Sum(vPI.InventoryCount),1,0)Over(Partition by ProductName Order By Month(vPI.InventoryDate)),
	-- 0)
	---- referencing and naming table.
	--From  dbo.vProductInventories as vPI
-- Time to plug into code!
--------------------------------------------------------------------------------------------------

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go
-- SHE WORKS!! An actual miracle.
--------------------------------------------------------------------------------------------------
-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- Columns to reference: ProductName, InventoryCount, InventoryDate, PreviousMonthCount.
-- New column to make for KPI case values - CountVsPreviousKPI.

-- Oh goody, we get to use Case! I assume that's what 1, 0, and -1 stand for. 

-- Let's throw in my notes for reference: 
-- Case has to start with case and end with end. Fun.
----CASE 
----    WHEN condition1 THEN result1
----    WHEN condition2 THEN result2
----    ELSE default_result
----END

-- Code to view the columns the way we need to from our most recent view w/ case syntax
--Select
--	ProductName,
--	InventoryDate,
--	InventoryCount,
--	PreviousMonthCount,
--	-- new column will have our case logic, naming it after the result set column name.
--	[CountVsPreviousKPI] = Case
--	-- When inventory count is higher then 1
--	When InventoryCount > PreviousMonthCount Then 1
--	-- when inventory count equals then 0
--	When InventoryCount = PreviousMonthCount Then 0
--	-- when inventory count is lower than previous month
--	Else -1
--	End
--From vProductInventoriesWithPreviousMonthCounts
--go

Create view vProductInventoriesWithPreviousMonthCountsWithKPIs with SchemaBinding
	As
		Select Top 1000000
		ProductName,
		InventoryDate,
		InventoryCount,
		PreviousMonthCount,
		[CountVsPreviousKPI] = 
		-- beginning case statement w/ logic I defined above. Using the view we made
		-- previously and referencing all columns from it in this statement.
		Case
			When InventoryCount > PreviousMonthCount Then 1
			When InventoryCount = PreviousMonthCount Then 0
			Else -1
		End
	From dbo.vProductInventoriesWithPreviousMonthCounts
go

 -- easy spot to drop when error arises w/ result set: 
----Drop view vProductInventoriesWithPreviousMonthCountsWithKPIs;
----go

-- Check that it works:
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go
-- IT WORKS!
--------------------------------------------------------------------------------------------------
-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- Question wants result set as a table, so making a TVF! 
-- CountVsPreviousKPI will be the value we're checking with 1, 0, -1. 
-- Columns to reference: ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousKPI.
-- CountVsPreviousKPI will be our filter column to call the function and return a table result set. 

-- It'll only need a single parameter and I'm naming the parameter after the filter column for ease of use.
-- Specifying int values only - we only need whole numbers.
Create function fProductInventoriesWithPreviousMonthCountsWithKPIs (@CountVsPreviousKPI int)
	-- Specifying I want a table returned.
	Returns Table
		As
		Return
		  (Select 
			ProductName, 
			InventoryDate,
			InventoryCount,
			PreviousMonthCount,
			CountVsPreviousKPI
           From vProductInventoriesWithPreviousMonthCountsWithKPIs
			-- Filter criteria
           Where CountVsPreviousKPI = @CountVsPreviousKPI);
go

-- Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go
-- Everything works!
/***************************************************************************************/