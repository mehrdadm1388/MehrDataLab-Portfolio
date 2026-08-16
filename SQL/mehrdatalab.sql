CREATE DATABASE MehrDataLab_Retail;
go

USE MehrDataLab_Retail;
go
SELECT * FROM dbo.Fact_Sales;
SELECT * FROM dbo.Dim_Customers;
SELECT * FROM dbo.Dim_Products;
SELECT * FROM dbo.Dim_Geography;

-- بررسی نوع داده‌های تخصیص‌یافته توسط to_sql
EXEC sp_help 'dbo.Fact_Sales';
go

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('Fact_Sales', 'Dim_Customers', 'Dim_Products', 'Dim_Geography')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
go

SELECT TOP 3 * FROM dbo.Fact_Sales;
SELECT TOP 3 * FROM dbo.Dim_Customers;
SELECT TOP 3 * FROM dbo.Dim_Products;
SELECT TOP 3 * FROM dbo.Dim_Geography;
go



-- چک NULL در ستون‌های کلیدی
SELECT 'Dim_Customers' AS TableName, COUNT(*) AS NullCount FROM dbo.Dim_Customers WHERE CustomerID IS NULL
UNION ALL
SELECT 'Dim_Products', COUNT(*) FROM dbo.Dim_Products WHERE ProductID IS NULL
UNION ALL
SELECT 'Dim_Geography', COUNT(*) FROM dbo.Dim_Geography WHERE GeoID IS NULL
UNION ALL
SELECT 'Fact_Sales', COUNT(*) FROM dbo.Fact_Sales WHERE OrderID IS NULL;

-- چک رکوردهای یتیم (Fact که به Dim وصل نمی‌شود) — پیش‌نیاز تعریف FK
SELECT f.CustomerID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Customers c ON f.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT f.ProductID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Products p ON f.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT f.GeoID FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
WHERE g.GeoID IS NULL;
go

-- ===================================================
-- Dim_Customers
-- ===================================================
ALTER TABLE dbo.Dim_Customers ALTER COLUMN CustomerID   INT NOT NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN CustomerName VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN Gender       VARCHAR(10)  NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN Age          SMALLINT     NULL;
ALTER TABLE dbo.Dim_Customers ALTER COLUMN GeoID        INT NOT NULL;

-- ===================================================
-- Dim_Products
-- ===================================================
ALTER TABLE dbo.Dim_Products ALTER COLUMN ProductID INT NOT NULL;
ALTER TABLE dbo.Dim_Products ALTER COLUMN Product   VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Products ALTER COLUMN Category  VARCHAR(50)  NOT NULL;

-- ===================================================
-- Dim_Geography
-- ===================================================
ALTER TABLE dbo.Dim_Geography ALTER COLUMN GeoID    INT NOT NULL;
ALTER TABLE dbo.Dim_Geography ALTER COLUMN City      VARCHAR(100) NOT NULL;
ALTER TABLE dbo.Dim_Geography ALTER COLUMN Province  VARCHAR(100) NOT NULL;

-- ===================================================
-- Fact_Sales
-- ===================================================
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
go

ALTER TABLE dbo.Dim_Customers  ADD CONSTRAINT PK_Dim_Customers  PRIMARY KEY (CustomerID);
ALTER TABLE dbo.Dim_Products   ADD CONSTRAINT PK_Dim_Products   PRIMARY KEY (ProductID);
ALTER TABLE dbo.Dim_Geography  ADD CONSTRAINT PK_Dim_Geography  PRIMARY KEY (GeoID);
ALTER TABLE dbo.Fact_Sales     ADD CONSTRAINT PK_Fact_Sales     PRIMARY KEY (OrderID);
go

ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerID)
    REFERENCES dbo.Dim_Customers(CustomerID);

ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Product FOREIGN KEY (ProductID)
    REFERENCES dbo.Dim_Products(ProductID);

ALTER TABLE dbo.Fact_Sales
    ADD CONSTRAINT FK_Fact_Geography FOREIGN KEY (GeoID)
    REFERENCES dbo.Dim_Geography(GeoID);

-- Dim_Customers نیز خودش به Dim_Geography وصل است
ALTER TABLE dbo.Dim_Customers
    ADD CONSTRAINT FK_Customer_Geography FOREIGN KEY (GeoID)
    REFERENCES dbo.Dim_Geography(GeoID);
go

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
go


USE MehrDataLab_Retail;

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
go


-- برای JOIN با Dim_Customers
CREATE NONCLUSTERED INDEX IX_FactSales_CustomerID
    ON dbo.Fact_Sales (CustomerID);

-- برای JOIN با Dim_Products
CREATE NONCLUSTERED INDEX IX_FactSales_ProductID
    ON dbo.Fact_Sales (ProductID);

-- برای JOIN با Dim_Geography
CREATE NONCLUSTERED INDEX IX_FactSales_GeoID
    ON dbo.Fact_Sales (GeoID);

-- برای فیلتر بر اساس بازه تاریخ (خیلی رایج در تحلیل فروش: "فروش ماه گذشته")
CREATE NONCLUSTERED INDEX IX_FactSales_OrderDate
    ON dbo.Fact_Sales (OrderDate);

-- Dim_Customers هم به Dim_Geography وصل است
CREATE NONCLUSTERED INDEX IX_DimCustomers_GeoID
    ON dbo.Dim_Customers (GeoID);
go

USE MehrDataLab_Retail;

-- آیا OrderID تکراری داریم؟ (باید صفر ردیف برگرداند چون PK داریم)
SELECT OrderID, COUNT(*) AS Cnt
FROM dbo.Fact_Sales
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- آیا CustomerID تکراری در Dim_Customers داریم؟
SELECT CustomerID, COUNT(*) AS Cnt
FROM dbo.Dim_Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

go


-- سن منفی یا غیرمنطقی
SELECT * FROM dbo.Dim_Customers WHERE Age <= 0 OR Age > 100;

-- تعداد یا قیمت صفر/منفی (از نظر کسب‌وکار بی‌معنی است)
SELECT * FROM dbo.Fact_Sales WHERE Quantity <= 0 OR UnitPrice <= 0;

-- تاریخ سفارش خارج از بازهٔ منطقی پروژه
SELECT MIN(OrderDate) AS EarliestOrder, MAX(OrderDate) AS LatestOrder
FROM dbo.Fact_Sales;

go

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
go
SELECT 
    ROUND(1 - (Sales / (Quantity * UnitPrice)), 2) AS ImpliedDiscountPct,
    COUNT(*) AS OrderCount
FROM dbo.Fact_Sales
GROUP BY ROUND(1 - (Sales / (Quantity * UnitPrice)), 2)
ORDER BY ImpliedDiscountPct;
go
SELECT 
    f.PaymentMethod,
    ROUND(1 - (f.Sales / (f.Quantity * f.UnitPrice)), 2) AS ImpliedDiscountPct,
    COUNT(*) AS OrderCount
FROM dbo.Fact_Sales f
GROUP BY f.PaymentMethod, ROUND(1 - (f.Sales / (f.Quantity * f.UnitPrice)), 2)
ORDER BY f.PaymentMethod, ImpliedDiscountPct;

go


-- مشتریانی که هیچ خریدی نکرده‌اند
SELECT c.CustomerID, c.CustomerName
FROM dbo.Dim_Customers c
LEFT JOIN dbo.Fact_Sales f ON c.CustomerID = f.CustomerID
WHERE f.OrderID IS NULL;
go

CREATE VIEW dbo.vw_SalesByCity AS
SELECT 
    g.City,
    g.Province,
    COUNT(f.OrderID)   AS TotalOrders,
    SUM(f.Sales)        AS TotalSales,
    SUM(f.Profit)        AS TotalProfit
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
GROUP BY g.City, g.Province;
go

SELECT * FROM dbo.vw_SalesByCity ORDER BY TotalSales DESC;

go

DROP VIEW dbo.vw_SalesByCity;
go 

CREATE VIEW dbo.vw_SalesByCity
WITH SCHEMABINDING
AS
SELECT 
    g.City,
    g.Province,
    COUNT_BIG(*)         AS TotalOrders,   -- COUNT_BIG اجباری است برای Indexed View
    SUM(f.Sales)         AS TotalSales,
    SUM(f.Profit)        AS TotalProfit
FROM dbo.Fact_Sales f
JOIN dbo.Dim_Geography g ON f.GeoID = g.GeoID
GROUP BY g.City, g.Province;

go

CREATE UNIQUE CLUSTERED INDEX IX_vw_SalesByCity
ON dbo.vw_SalesByCity (City, Province);
go

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


go


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

go

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

go

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
    NTILE(4) OVER (ORDER BY TotalSpend DESC) AS SpendQuartile  -- 1=بالاترین
FROM CustomerValue
ORDER BY TotalSpend DESC;
go

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

go

SELECT
    SalesPerson,
    COUNT(OrderID)     AS TotalOrders,
    SUM(Sales)          AS TotalRevenue,
    DENSE_RANK() OVER (ORDER BY SUM(Sales) DESC) AS RevenueRank
FROM dbo.Fact_Sales
GROUP BY SalesPerson
ORDER BY RevenueRank;

go

SELECT
    OBJECT_NAME(c.object_id) AS TableName,
    c.name                   AS ColumnName,
    t.name                   AS DataType,
    c.max_length,
    c.is_nullable,
    CASE OBJECT_NAME(c.object_id)
        WHEN 'Fact_Sales' THEN 
            CASE c.name
                WHEN 'OrderID'       THEN 'شناسه یکتای هر سفارش (PK)'
                WHEN 'Sales'         THEN 'فروش خالص پس از اعمال تخفیف'
                WHEN 'Profit'        THEN 'سود خالص هر سفارش'
                WHEN 'UnitPrice'     THEN 'قیمت واحد قبل از تخفیف'
                ELSE ''
            END
        WHEN 'Dim_Customers' THEN
            CASE c.name
                WHEN 'CustomerID' THEN 'شناسه یکتای مشتری (PK)'
                ELSE ''
            END
        ELSE ''
    END AS BusinessDefinition
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE OBJECT_NAME(c.object_id) IN ('Fact_Sales','Dim_Customers','Dim_Products','Dim_Geography')
ORDER BY TableName, c.column_id;

go 

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