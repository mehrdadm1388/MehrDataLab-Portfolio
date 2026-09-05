/* =====================================================================
   MehrDataLab_Retail — SQL Server Project Script
   Author: Mehrdad
   Description: Full SQL layer of the MehrDataLab Retail Chain project.
   Source data loaded from Python (pandas + SQLAlchemy) into SQL Server.
   ===================================================================== */


/* =====================================================================
   SECTION 1: SETUP
   Create the database and confirm the raw tables loaded by Python
   (via SQLAlchemy .to_sql) exist and are accessible.
   ===================================================================== */

CREATE DATABASE MehrDataLab_Retail;
GO

USE MehrDataLab_Retail;
GO

SELECT * FROM dbo.Fact_Sales;
SELECT * FROM dbo.Dim_Customers;
SELECT * FROM dbo.Dim_Products;
SELECT * FROM dbo.Dim_Geography;
GO


/* =====================================================================
   SECTION 2: EXPLORATION
   Initial inspection of table structure and raw data types as
   assigned automatically by pandas.to_sql(). This step tells us
   what needs to be fixed in the Type Fix section below.
   ===================================================================== */

-- Quick structural summary of the main fact table
EXEC sp_help 'dbo.Fact_Sales';
GO

-- Full column-level metadata for all 4 tables (data types, nullability)
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Fact_Sales', 'Dim_Customers', 'Dim_Products', 'Dim_Geography')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

-- Visual sample of each table
SELECT TOP 3 * FROM dbo.Fact_Sales;
SELECT TOP 3 * FROM dbo.Dim_Customers;
SELECT TOP 3 * FROM dbo.Dim_Products;
SELECT TOP 3 * FROM dbo.Dim_Geography;
GO

-- Sanity checks before altering schema: NULLs in key columns
SELECT 'Dim_Customers' AS TableName, COUNT(*) AS NullCount FROM dbo.Dim_Customers WHERE CustomerID IS NULL
UNION ALL
SELECT 'Dim_Products', COUNT(*) FROM dbo.Dim_Products WHERE ProductID IS NULL
UNION ALL
SELECT 'Dim_Geography', COUNT(*) FROM dbo.Dim_Geography WHERE GeoID IS NULL
UNION ALL
SELECT 'Fact_Sales', COUNT(*) FROM dbo.Fact_Sales WHERE OrderID IS NULL;
GO

-- Orphan record check: Fact rows with no matching Dim row
-- (Must be run and confirmed empty BEFORE defining Foreign Keys)
SELECT f.CustomerID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT f.ProductID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Products p ON f.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT f.GeoID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
WHERE g.GeoID IS NULL;
GO


/* =====================================================================
   SECTION 3: TYPE FIX
   pandas.to_sql() assigns conservative default types (e.g. BIGINT,
   VARCHAR(MAX), FLOAT). Here we align every column with its real
   business type: proper INT sizes, DECIMAL for money, NOT NULL
   constraints, and bounded VARCHAR lengths.
   ===================================================================== */

-- Dim_Customers
ALTER TABLE dbo.Dim_Customers ALTER COLUMN CustomerID   INT NOT NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN CustomerName VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN Gender       VARCHAR(10)  NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN Age          SMALLINT     NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN GeoID        INT NOT NULL;

-- Dim_Products
ALTER TABLE dbo.Dim_Products ALTER COLUMN ProductID INT NOT NULL;
ALTER TABLE dbo.Dim_Products ALTER COLUMN Product   VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Products ALTER COLUMN Category  VARCHAR(50)  NOT NULL;

-- Dim_Geography
ALTER TABLE dbo.Dim_Geography ALTER COLUMN GeoID    INT NOT NULL;
ALTER TABLE dbo.Dim_Geography ALTER COLUMN City      VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Geography ALTER COLUMN Province  VARCHAR(100) NOT NULL;

-- Fact_Sales
ALTER TABLE dbo.Fact_Sales ALTER COLUMN OrderID       INT NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN OrderDate     DATETIME     NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN CustomerID    INT NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN ProductID     INT NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN GeoID         INT NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN Quantity      INT NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN UnitPrice     DECIMAL(10,2) NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN Sales         DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN Profit        DECIMAL(12,2) NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN PaymentMethod VARCHAR(20)  NOT NULL;
ALTER TABLE dbo.Fact_Sales ALTER COLUMN SalesPerson   VARCHAR(100) NOT NULL;
GO


/* =====================================================================
   SECTION 4: CONSTRAINTS (Primary & Foreign Keys)
   Completes the Star Schema: one PK per table, and FKs linking
   Fact_Sales to each Dimension table (plus Dim_Customers -> Dim_Geography).
   ===================================================================== */

-- Primary Keys
ALTER TABLE dbo.Dim_Customers  ADD CONSTRAINT PK_Dim_Customers  PRIMARY KEY (CustomerID);
ALTER TABLE dbo.Dim_Products   ADD CONSTRAINT PK_Dim_Products   PRIMARY KEY (ProductID);
ALTER TABLE dbo.Dim_Geography  ADD CONSTRAINT PK_Dim_Geography  PRIMARY KEY (GeoID);
ALTER TABLE dbo.Fact_Sales     ADD CONSTRAINT PK_Fact_Sales     PRIMARY KEY (OrderID);
GO

-- Foreign Keys
ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerID)
    REFERENCES dbo.Dim_Customers(CustomerID);

ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Product FOREIGN KEY (ProductID)
    REFERENCES dbo.Dim_Products(ProductID);

ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Geography FOREIGN KEY (GeoID)
    REFERENCES dbo.Dim_Geography(GeoID);

-- Dim_Customers also links to Dim_Geography (customer's home city)
ALTER TABLE dbo.Dim_Customers
    ADD CONSTRAINT FK_Customer_Geography FOREIGN KEY (GeoID)
    REFERENCES dbo.Dim_Geography(GeoID);
GO

-- Verify the full relational model via system catalog views
SELECT 
    fk.name AS FK_Name,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id;
GO


/* =====================================================================
   SECTION 5: INDEXING
   Foreign Keys do NOT automatically create indexes in SQL Server.
   These non-clustered indexes speed up the JOINs and date filters
   used throughout the Validation, Views, and KPI sections below.
   ===================================================================== */

USE MehrDataLab_Retail;
GO

-- Confirm current indexes before adding new ones
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('Fact_Sales','Dim_Customers','Dim_Products','Dim_Geography')
  AND i.name IS NOT NULL
ORDER BY t.name;
GO

-- For JOINs with Dim_Customers
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerID
    ON dbo.Fact_Sales (CustomerID);

-- For JOINs with Dim_Products
CREATE NONCLUSTERED INDEX IX_FactSales_ProductID
    ON dbo.Fact_Sales (ProductID);

-- For JOINs with Dim_Geography
CREATE NONCLUSTERED INDEX IX_FactSales_GeoID
    ON dbo.Fact_Sales (GeoID);

-- For date-range filters (e.g. "sales last month")
CREATE NONCLUSTERED INDEX IX_FactSales_OrderDate
    ON dbo.Fact_Sales (OrderDate);

-- Dim_Customers also joins to Dim_Geography
CREATE NONCLUSTERED INDEX IX_DimCustomers_GeoID
    ON dbo.Dim_Customers (GeoID);
GO


/* =====================================================================
   SECTION 6: VALIDATION
   Structural, range, and business-logic checks performed AFTER
   constraints/indexes are in place, to confirm data quality before
   any analytical view or KPI is built on top of it.
   ===================================================================== */

USE MehrDataLab_Retail;
GO

-- Duplicate check: OrderID (should return 0 rows, PK already enforces this)
SELECT OrderID, COUNT(*) AS Cnt
FROM dbo.Fact_Sales
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- Duplicate check: CustomerID
SELECT CustomerID, COUNT(*) AS Cnt
FROM dbo.Dim_Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;
GO

-- Range check: implausible age values
SELECT * FROM dbo.Dim_Customers WHERE Age <= 0 OR Age > 100;

-- Range check: zero/negative quantity or price (meaningless in business terms)
SELECT * FROM dbo.Fact_Sales WHERE Quantity <= 0 OR UnitPrice <= 0;

-- Range check: reasonable order date boundaries
SELECT MIN(OrderDate) AS EarliestOrder, MAX(OrderDate) AS LatestOrder
FROM dbo.Fact_Sales;
GO

-- Business-logic check: does Sales = Quantity * UnitPrice?
-- (Finding: it doesn't — see the discount analysis below)
SELECT 
    OrderID,
    Quantity,
    UnitPrice,
    Sales AS RecordedSales,
    (Quantity * UnitPrice) AS CalculatedSales,
    Sales - (Quantity * UnitPrice) AS Difference
FROM dbo.Fact_Sales
WHERE Sales <> (Quantity * UnitPrice)
ORDER BY ABS(Sales - (Quantity * UnitPrice)) DESC;
GO

-- Discovery: Sales includes a hidden discount not stored as its own column.
-- This confirms the discount is applied in 5 discrete tiers (0%-20%).
SELECT 
    ROUND(1 - (Sales / (Quantity * UnitPrice)), 2) AS ImpliedDiscountPct,
    COUNT(*) AS OrderCount
FROM dbo.Fact_Sales
GROUP BY ROUND(1 - (Sales / (Quantity * UnitPrice)), 2)
ORDER BY ImpliedDiscountPct;
GO

-- Confirm the discount tiers are independent of PaymentMethod
SELECT 
    f.PaymentMethod,
    ROUND(1 - (f.Sales / (f.Quantity * f.UnitPrice)), 2) AS ImpliedDiscountPct,
    COUNT(*) AS OrderCount
FROM dbo.Fact_Sales f
GROUP BY f.PaymentMethod, ROUND(1 - (f.Sales / (f.Quantity * f.UnitPrice)), 2)
ORDER BY f.PaymentMethod, ImpliedDiscountPct;
GO

-- Referential check (informational, not an error): customers with zero purchases
SELECT c.CustomerID, c.CustomerName
FROM dbo.Dim_Customers c
LEFT JOIN dbo.Fact_Sales f ON c.CustomerID = f.CustomerID
WHERE f.OrderID IS NULL;
GO


/* =====================================================================
   SECTION 7: VIEWS
   Reusable analytical views. vw_SalesByCity is SCHEMABINDING + indexed
   (materialized) for fast geo-level rollups. vw_FactSales_Enriched adds
   the DiscountPct / ProfitMarginPct columns derived in Section 6.
   ===================================================================== */

-- Standard (non-indexed) version — kept here for reference only.
-- The SCHEMABINDING version below replaces it.
-- CREATE VIEW dbo.vw_SalesByCity AS
-- SELECT
--     g.City,
--     g.Province,
--     COUNT(f.OrderID)   AS TotalOrders,
--     SUM(f.Sales)       AS TotalSales,
--     SUM(f.Profit)      AS TotalProfit
-- FROM dbo.Fact_Sales f
-- JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
-- GROUP BY g.City, g.Province;

CREATE VIEW dbo.vw_SalesByCity
WITH SCHEMABINDING
AS
SELECT 
    g.City,
    g.Province,
    COUNT_BIG(*)         AS TotalOrders,   -- COUNT_BIG is required for indexed views
    SUM(f.Sales)         AS TotalSales,
    SUM(f.Profit)        AS TotalProfit
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
GROUP BY g.City, g.Province;
GO

-- Materialize the view: turns it into a physically stored, auto-updating index
CREATE UNIQUE CLUSTERED INDEX IX_vw_SalesByCity
ON dbo.vw_SalesByCity (City, Province);
GO

-- Row-level enriched view: adds discount % and profit margin % per order
CREATE OR ALTER VIEW dbo.vw_FactSales_Enriched
WITH SCHEMABINDING
AS
SELECT
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    GeoID,
    Quantity,
    UnitPrice,
    Sales,
    Profit,
    PaymentMethod,
    SalesPerson,
    CAST(1.0 - (Sales / (Quantity * UnitPrice)) AS DECIMAL(4,2)) AS DiscountPct,
    CAST((Profit / NULLIF(Sales, 0)) * 100 AS DECIMAL(5,2))       AS ProfitMarginPct
FROM dbo.Fact_Sales;
GO

-- Quick check
SELECT * FROM dbo.vw_SalesByCity ORDER BY TotalSales DESC;
GO


/* =====================================================================
   SECTION 8: KPI QUERIES
   Analytical queries built with CTEs and Window Functions, feeding
   the Power BI dashboard (monthly trend, top products, customer
   segmentation, geo performance, salesperson ranking).
   ===================================================================== */

-- KPI 1: Monthly sales trend with month-over-month growth %
WITH MonthlySales AS (
    SELECT
        FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth,
        SUM(Sales) AS TotalSales
    FROM dbo.Fact_Sales
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT
    SalesMonth,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY SalesMonth) AS PrevMonthSales,
    CAST(
        (TotalSales - LAG(TotalSales) OVER (ORDER BY SalesMonth)) 
        / NULLIF(LAG(TotalSales) OVER (ORDER BY SalesMonth), 0) * 100 
    AS DECIMAL(5,2)) AS MoM_Growth_Pct
FROM MonthlySales
ORDER BY SalesMonth;
GO

-- KPI 2: Top-3 products per category, ranked by total sales
WITH ProductRank AS (
    SELECT
        p.Category,
        p.Product,
        SUM(f.Sales) AS TotalSales,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(f.Sales) DESC) AS RankInCategory
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Products p ON f.ProductID = p.ProductID
    GROUP BY p.Category, p.Product
)
SELECT * FROM ProductRank WHERE RankInCategory <= 3
ORDER BY Category, RankInCategory;
GO

WITH ProductSales AS (
    SELECT
        p.Category,
        p.Product,
        SUM(f.Sales) AS TotalSales
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Products p
        ON f.ProductID = p.ProductID
    GROUP BY
        p.Category,
        p.Product
)
SELECT
    Category,
    Product,
    TotalSales,

    ROW_NUMBER() OVER (
        PARTITION BY Category
        ORDER BY TotalSales DESC
    ) AS RowNumber

FROM ProductSales
ORDER BY
    Category,
    RowNumber;
go

WITH ProductSales AS (
    SELECT
        p.Category,
        p.Product,
        SUM(f.Sales) AS TotalSales
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Products p
        ON f.ProductID = p.ProductID
    GROUP BY
        p.Category,
        p.Product
)
SELECT
    Category,
    Product,
    TotalSales,

    ROW_NUMBER() OVER (
        PARTITION BY Category
        ORDER BY TotalSales DESC
    ) AS RowNumber,

    RANK() OVER (
        PARTITION BY Category
        ORDER BY TotalSales DESC
    ) AS RankNumber,

    DENSE_RANK() OVER (
        PARTITION BY Category
        ORDER BY TotalSales DESC
    ) AS DenseRankNumber

FROM ProductSales
ORDER BY
    Category,
    TotalSales DESC;
go
-- KPI 3: Customer segmentation by spend quartile (NTILE)
WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSpend
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT
    CustomerID,
    CustomerName,
    TotalSpend,
    NTILE(4) OVER (ORDER BY TotalSpend DESC) AS SpendQuartile  -- 1 = top quartile
FROM CustomerValue
ORDER BY TotalSpend DESC;
GO
WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSpend
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
),
CustomerDecile AS (
    SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        NTILE(5) OVER (ORDER BY TotalSpend DESC) AS SpendQuintile
    FROM CustomerValue
)
SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        SpendQuintile,
        CASE SpendQuintile
             WHEN 1 THEN 'VIP'
             WHEN 5 THEN 'At Risk'
             ELSE 'Normal'
             END as Statuses
FROM CustomerDecile
where SpendQuintile=1 or SpendQuintile=5

ORDER BY TotalSpend DESC;
GO

WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSpend
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
),
CustomerDecile AS (
    SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        NTILE(5) OVER (ORDER BY TotalSpend DESC) AS SpendQuintile

    FROM CustomerValue
)
SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        SpendQuintile,
        CASE 
            WHEN SpendQuintile = 1 THEN 'VIP'
            WHEN SpendQuintile BETWEEN 2 AND 4 THEN 'Regular'
            WHEN SpendQuintile = 5 THEN 'At Risk'
         END  Statuses
FROM CustomerDecile


ORDER BY TotalSpend DESC;
go



WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSpend
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
),
CustomerDecile AS (
    SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        NTILE(5) OVER (ORDER BY TotalSpend DESC) AS SpendQuintile

    FROM CustomerValue
)
SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        SpendQuintile,
        CASE 
            WHEN SpendQuintile = 1 THEN 'VIP'
            WHEN SpendQuintile BETWEEN 2 AND 4 THEN 'Regular'
            WHEN SpendQuintile = 5 THEN 'At Risk'
         END  Statuses,
          CASE 
            WHEN SpendQuintile = 1 THEN 'Invite to loyalty program'
            WHEN SpendQuintile BETWEEN 2 AND 4 THEN 'Monitor for upsell opportunity'
            WHEN SpendQuintile = 5 THEN 'Send win-back campaign'
         END RecommendedAction
FROM CustomerDecile


ORDER BY TotalSpend DESC;
go


WITH CustomerValue AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(f.Sales) AS TotalSpend
    FROM dbo.Fact_Sales f
    JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
),
CustomerDecile AS (
    SELECT
        CustomerID,
        CustomerName,
        TotalSpend,
        NTILE(10) OVER (ORDER BY TotalSpend DESC) AS SpendDecile
    FROM CustomerValue
)
SELECT
    SpendDecile,
    COUNT(*) AS CustomerCount,
    AVG(TotalSpend) AS AvgSpendInDecile,
    MIN(TotalSpend) AS MinSpend,
    MAX(TotalSpend) AS MaxSpend
FROM CustomerDecile
GROUP BY SpendDecile
ORDER BY SpendDecile;
go

-- KPI 4: Average order value & profit margin by city
SELECT
    g.City,
    COUNT(f.OrderID)               AS TotalOrders,
    SUM(f.Sales)                   AS TotalRevenue,
    CAST(AVG(f.Sales) AS DECIMAL(10,2)) AS AvgOrderValue,
    CAST(SUM(f.Profit) * 100.0 / NULLIF(SUM(f.Sales),0) AS DECIMAL(5,2)) AS ProfitMarginPct
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
GROUP BY g.City
ORDER BY TotalRevenue DESC;
GO

-- KPI 5: Salesperson performance ranking
SELECT
    SalesPerson,
    COUNT(OrderID)     AS TotalOrders,
    SUM(Sales)          AS TotalRevenue,
    DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC) AS RevenueRank
FROM dbo.Fact_Sales
GROUP BY SalesPerson
ORDER BY RevenueRank;
GO

-- Structural metadata query used by build_data_dictionary.py
-- (Business definitions are added in Python, not here, to avoid
--  VARCHAR/NVARCHAR Persian-text encoding issues in T-SQL.)
SELECT
    OBJECT_NAME(c.object_id) AS TableName,
    c.name                   AS ColumnName,
    t.name                   AS DataType,
    c.max_length             AS MaxLength,
    c.is_nullable            AS IsNullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE OBJECT_NAME(c.object_id) IN ('Fact_Sales','Dim_Customers','Dim_Products','Dim_Geography')
ORDER BY TableName, c.column_id;
GO
SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
JOIN sys.tables t
    ON c.object_id = t.object_id
JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
WHERE t.name IN (
    'Fact_Sales',
    'Dim_Customers',
    'Dim_Products',
    'Dim_Geography'
)
ORDER BY
    t.name,
    c.column_id;
go 
select object_id from sys.columns
go
SELECT
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.columns c
JOIN sys.tables t
    ON c.object_id = t.object_id
ORDER BY t.name, c.column_id;
go
SELECT
    t.name AS TableName,
    c.name AS ColumnName
FROM sys.columns c
JOIN sys.tables t
    ON c.object_id = t.object_id
WHERE t.name IN (
    'Fact_Sales',
    'Dim_Customers',
    'Dim_Products',
    'Dim_Geography'
)
ORDER BY t.name, c.column_id;
go


SELECT * FROM dbo.Dim_Geography;
GO

ALTER TABLE dbo.Dim_Geography
ADD Latitude DECIMAL(9,6) NULL;

ALTER TABLE dbo.Dim_Geography
ADD Longitude DECIMAL(9,6) NULL;
GO

UPDATE dbo.Dim_Geography
SET Latitude = 32.654616,
    Longitude = 51.667995
WHERE City = 'Isfahan';

UPDATE dbo.Dim_Geography
SET Latitude = 36.260530,
    Longitude = 59.616780
WHERE City = 'Mashhad';

UPDATE dbo.Dim_Geography
SET Latitude = 38.080000,
    Longitude = 46.291943
WHERE City = 'Tabriz';

UPDATE dbo.Dim_Geography
SET Latitude = 29.591768,
    Longitude = 52.583698
WHERE City = 'Shiraz';

UPDATE dbo.Dim_Geography
SET Latitude = 35.689200,
    Longitude = 51.389000
WHERE City = 'Tehran';
GO


