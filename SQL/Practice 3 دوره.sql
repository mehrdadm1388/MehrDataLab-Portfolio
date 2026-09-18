use toplearn_db
go

create table customer(
custid  int primary key  not null ,
Fname nvarchar(30)  not null,
lname nvarchar(30)  not null,
email nvarchar(100)  unique not null,
)
go
use TSQLV4
go
SELECT 
    o.orderid,
    o.freight,
    CASE 
        WHEN o.freight < 50 THEN 'Low'
        WHEN o.freight >= 50 AND o.freight <= 200 THEN 'Medium'
        WHEN o.freight > 200 THEN 'High'
    END AS freight_category
FROM Sales.Orders o
ORDER BY o.freight DESC, o.orderid DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

go 
SELECT col1, col2 
FROM dbo.T1
WHERE 
    IIF(col1 = 0, 0, IIF(col2/col1 > 2, 1, 0)) = 1;
go

use TSQLV4
go

select 
     c.custid,
     case 
        when count(o.orderid)  IS NULL then 0
        else count(o.orderid)
    end as countorder
         



from sales.Customers c left join 
     sales.Orders o on c.custid=o.custid

GROUP BY c.custid
go

SELECT
    c.custid,
    COUNT(o.orderid) AS countorder
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
    ON c.custid = o.custid
GROUP BY c.custid;
go



SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid
INNER JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;

GO


SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid
full JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;
go
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid
LEFT OUTER JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;

go

SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Orders AS O
INNER JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid
RIGHT OUTER JOIN Sales.Customers AS C ON O.custid = C.custid;
GO
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
LEFT OUTER JOIN
    (Sales.Orders AS O
     INNER JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid)
ON C.custid = O.custid;
GO

select
E1.empid as empleft,
E2.empid as empright
FROM HR.Employees AS E1
INNER JOIN HR.Employees AS E2
on e1.empid<e2.empid
order by e1.empid , e2.empid
go

select 
      e.empid,
      a.freight
from HR.Employees as e
cross apply
(select top(1) freight 
from sales.Orders as o
where  e.empid= o.empid
order by o.freight desc ) as a
go
SELECT empid, orderid, freight
FROM Sales.Orders AS O1
WHERE freight =
    (SELECT MAX(O2.freight)
     FROM Sales.Orders AS O2
     WHERE O2.empid = O1.empid);

go

SELECT empid, orderid, freight
FROM Sales.Orders AS O1
WHERE NOT EXISTS
    (SELECT *
     FROM Sales.Orders AS O2
     WHERE O2.empid = O1.empid
       AND O2.freight > O1.freight);

go

SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN (SELECT custid FROM Sales.Orders);
go 
SELECT custid, companyname
FROM Sales.Customers as c 
WHERE  NOT exists (SELECT 1 FROM Sales.Orders AS O
    WHERE O.custid = C.custid
);
go
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN (
    SELECT custid FROM Sales.Orders WHERE custid IS NOT NULL
);
go
select e.empid,
       a.totalfre,
       a.freight_category


from [HR].[Employees] as e
left join 
(select o.empid,
       sum(o.freight) as totalfre,  
       case 
          WHEN sum(o.freight) <5000 THEN 'Low'
        WHEN sum(o.freight) >= 5000 AND sum(o.freight) <= 7500 THEN 'Medium'
        WHEN sum(o.freight) > 7500 THEN 'High'
        END AS freight_category,
        (SELECT COUNT(DISTINCT o2.custid) FROM Sales.Orders as o2
        WHERE o2.empid = o.empid
        ) AS UniqueCustomers

from [Sales].[Orders] as o
group by o.empid) as a
on a.empid=e.empid
go

SELECT
    e.empid,
    ISNULL(a.TotalSales, 0) AS TotalSales,
    CASE
        WHEN ISNULL(a.TotalSales, 0) = 0 THEN 'Needs Improvement'
        WHEN a.TotalSales < 100000 THEN 'Needs Improvement'
        WHEN a.TotalSales <= 150000 THEN 'Good'
        ELSE 'Excellent'
    END AS PerformanceLevel,
    (
        SELECT COUNT(DISTINCT o2.custid)
        FROM Sales.Orders AS o2
        WHERE o2.empid = e.empid
    ) AS UniqueCustomers
FROM HR.Employees AS e
LEFT JOIN
(
    SELECT
        o.empid,
        SUM(od.unitprice * od.qty * (1 - od.discount)) AS TotalSales
    FROM Sales.Orders AS o
    INNER JOIN Sales.OrderDetails AS od
        ON o.orderid = od.orderid
    GROUP BY o.empid
) AS a
    ON a.empid = e.empid
ORDER BY
    ISNULL(a.TotalSales, 0) DESC;


go

SELECT
      E.EMPID,
      ISNULL(A.TOTLAS,0) AS Totalsales ,
      CASE
          WHEN ISNULL(A.TOTLAS,0) = 0 THEN 'Needs Improvement'
          WHEN A.TOTLAS <100000 THEN 'Needs Improvement'
          WHEN A.TOTLAS <150000 THEN 'GOODS'
          ELSE 'EXCELENT'
       END AS Salesquality,
       (SELECT COUNT(DISTINCT O.CUSTID)
       FROM [Sales].[Orders] AS O
       WHERE E.empid=O.empid) AS UNIQUESELES
              
FROM [HR].[Employees] AS E
LEFT JOIN(
       SELECT O2.EMPID,
       SUM(OD.UNITPRICE * OD.QTY * (1-OD.DISCOUNT)) AS TOTLAS

FROM [Sales].[Orders] AS O2
INNER JOIN [Sales].[OrderDetails] AS OD
          ON OD.ORDERID=O2.ORDERID
          GROUP BY O2.EMPID) AS A
ON A.EMPID = E.EMPID
ORDER BY ISNULL(a.TOTLAS, 0) DESC
GO
SELECT orderyear, numcusts
FROM (
    SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
    FROM (
        SELECT YEAR(orderdate) AS orderyear, custid
        FROM Sales.Orders
    ) AS D1
    GROUP BY orderyear
) AS D2
WHERE numcusts > 70;


GO



WITH C1 AS (
    SELECT YEAR(orderdate) AS orderyear, custid
    FROM Sales.Orders
),
C2 AS (
    SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
    FROM C1
    GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;


GO

SELECT empid, totalfreight
FROM
(
    SELECT empid, SUM(freight) AS totalfreight
    FROM Sales.Orders
    GROUP BY empid
) AS A
WHERE totalfreight >
(
    SELECT AVG(totalfreight)
    FROM (
    SELECT empid, SUM(freight) AS totalfreight
    FROM Sales.Orders
    GROUP BY empid
) AS A
);

go
USE  toplearn
GO
DROP TABLE Employees
GO
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name NVARCHAR(50),
    ManagerID INT
);

INSERT INTO Employees VALUES 
(1, 'REZA(Managing Director)', NULL),    -- مدیر عامل مدیر ندارد
(2, ' ALI(Technical Manager)', 1),        -- علی زیر نظر رضا
(3, ' SARA(Sales Manager)', 1),      -- سارا زیر نظر رضا
(4, ' MEHRDAD(Programmer)', 2),    -- مهدی زیر نظر علی
(5, ' MINA(Designer)', 2);          -- مینا زیر نظر علی
GO

WITH OrgChart AS (
    -- ۱. بخش لنگر (Anchor): پیدا کردن مدیر کل (کسی که مدیر ندارد)
    SELECT 
        EmployeeID, 
        Name, 
        ManagerID, 
        1 AS Level -- سطح اول
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- ۲. بخش بازگشتی (Recursive): پیدا کردن زیردستان
    SELECT 
        e.EmployeeID, 
        e.Name, 
        e.ManagerID, 
        o.Level + 1 -- هر مرحله پایین‌تر می‌رویم، یک واحد به سطح اضافه می‌شود
    FROM Employees e
    INNER JOIN OrgChart o ON e.ManagerID = o.EmployeeID
)

SELECT 
    Level,
    REPLICATE('---', Level - 1) + Name AS Path
FROM OrgChart
ORDER BY Level
OPTION (MAXRECURSION 1);
GO
WITH OrgChart AS (
    SELECT EmployeeID, Name, ManagerID, 1 AS Level
    FROM Employees WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.Name, e.ManagerID, o.Level + 1
    FROM Employees e
    INNER JOIN OrgChart o ON e.ManagerID = o.EmployeeID
    WHERE o.Level < 2 -- این شرط باعث می‌شود بازگشت به صورت نرم و بدون خطا متوقف شود
)
SELECT * FROM OrgChart;
GO
use toplearn
go
CREATE TABLE dbo.Products
(
    ProductID INT IDENTITY(1,1),
    ProductName VARCHAR(50)
);

CREATE TABLE dbo.ProductAudit
(
    AuditID INT IDENTITY(1000,1),
    ProductID INT
);
go
CREATE TRIGGER trg_ProductInsert
ON dbo.Products
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.ProductAudit(ProductID)
    SELECT ProductID
    FROM inserted;
END;

go
INSERT INTO dbo.Products(ProductName)
VALUES ('Laptop');

go
SELECT
    @@IDENTITY as ide,
    SCOPE_IDENTITY()  as sco;


go
USE TSQLV4
GO
CREATE FUNCTION Sales.GetCustomerOrders
(
    @CustID INT
)
RETURNS @Result TABLE
(
    OrderID INT,
    OrderDate DATE,
    Freight MONEY
)
AS
BEGIN

    INSERT INTO @Result
    SELECT
        orderid,
        orderdate,
        freight
    FROM Sales.Orders
    WHERE custid = @CustID;

    RETURN;
END;

GO
SELECT *
FROM Sales.GetCustomerOrders(1);
GO
CREATE VIEW Sales.OrderDetailsView
AS
SELECT 
    O.orderid,
    O.orderdate,
    O.custid,
    OD.productid,
    OD.qty,
    OD.unitprice
FROM Sales.Orders AS O
INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;

GO
SELECT *
FROM Sales.OrderDetailsView
WHERE custid = 1
  AND orderdate >= '2015-01-01';

GO
USE toplearn_db
GO
CREATE TABLE dbo.Employees (
    EmployeeID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Department NVARCHAR(50),
    JobTitle NVARCHAR(50),
    IsSeniorManager BIT  -- 1 = Senior Manager, 0 = Not
);

INSERT INTO dbo.Employees (EmployeeID, FullName, Department, JobTitle, IsSeniorManager)
VALUES
    (1, 'Ali Rezaei', 'IT', 'Senior Manager', 1),
    (2, 'Sara Ahmadi', 'IT', 'Developer', 0),
    (3, 'Mohammad Karimi', 'HR', 'Senior Manager', 1),
    (4, 'Zahra Mohammadi', 'Finance', 'Senior Manager', 1),
    (5, 'Reza Hashemi', 'HR', 'HR Specialist', 0);
GO
USE TSQLV4
GO
CREATE FUNCTION dbo.GetSeniorManagers (@Department NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT EmployeeID, FullName, Department, JobTitle
    FROM dbo.Employees
    WHERE IsSeniorManager = 1
      AND (Department = @Department OR @Department IS NULL)  -- اگر NULL باشد، همه را نشان بده
);
GO
SELECT * FROM dbo.GetSeniorManagers('IT');
GO
SELECT * FROM dbo.GetSeniorManagers(NULL);
go

alter VIEW Sales.USACusts WITH ENCRYPTION
AS
SELECT custid, companyname FROM Sales.Customers WHERE country = N'USA';
GO
EXEC sp_helptext 'Sales.USACusts';

go

CREATE FUNCTION dbo.TopOrders(@custid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
    SELECT TOP (@n) orderid, orderdate
    FROM Sales.Orders
    WHERE custid = @custid
    ORDER BY orderdate DESC;
GO

SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
CROSS APPLY dbo.TopOrders(C.custid, 3) AS A;
go
CREATE VIEW Sales.VCustOrderSummary
WITH SCHEMABINDING
AS 
SELECT 
       O.custid,
       COUNT(O.ORDERID) AS COUNTORDER,
       SUM(O.FREIGHT) AS TOTALFREIGHT


FROM [Sales].[Orders] AS O
GROUP BY O.custid
GO
DROP VIEW Sales.VUSAOrders
GO
CREATE VIEW Sales.VUSAOrders
AS
SELECT 
      CustID, contactname, Country
FROM [Sales].[Customers]
WHERE Country = 'USA'
WITH CHECK OPTION
GO 
SET IDENTITY_INSERT Sales.Customers ON
INSERT INTO Sales.VUSAOrders (CustID, contactname, Country)
VALUES (92 , 'ALFKI', 'USA', 'Alfreds Futterkiste')
SET IDENTITY_INSERT Sales.Customers OFF;
GO
DROP VIEW Sales.VUSAOrders
GO
CREATE VIEW Sales.VUSAOrders
WITH SCHEMABINDING
AS
SELECT orderid, custid, orderdate, freight
FROM Sales.Orders
WHERE custid IN (SELECT custid FROM Sales.Customers WHERE country = N'USA')
WITH CHECK OPTION;
GO

CREATE VIEW Sales.USGoodCustomers
AS
SELECT
    custid,
    companyname
FROM Sales.USACusts
WHERE companyname LIKE '%B';
go
SELECT custid, NULL AS region FROM Sales.Customers
UNION
SELECT custid, region FROM Sales.Customers
go
SELECT
    custid,
    orderid,
    orderdate,
    freight,
     SUM(freight) OVER(
        PARTITION BY custid
        ORDER BY orderdate
    ) AS rn
FROM [Sales].[Orders];
go
DROP TABLE IF EXISTS Sales.EmployeeCustomerPivot;
SELECT
      CUSTID,[1],[2],[3],[4],[5],[6],[7],[8],[9]
 INTO Sales.EmployeeCustomerPivot
FROM 
(
    SELECT custid, empid, FREIGHT
    FROM [Sales].[Orders]
) AS D
PIVOT
(
    SUM(FREIGHT)
    FOR EMPID IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
) AS P;
GO

DECLARE @cols NVARCHAR(MAX);
DECLARE @sql  NVARCHAR(MAX);


SELECT @cols =
    STRING_AGG(QUOTENAME(empid), ',')
FROM
(
    SELECT DISTINCT empid
    FROM Sales.Orders
) AS C;


SET @sql = '
SELECT custid, ' + @cols + '
FROM
(
    SELECT custid , empid, FREIGHT
    FROM Sales.Orders
) AS D
PIVOT
(
    SUM(FREIGHT)
    FOR empid IN (' + @cols + ')
) AS P;';

EXEC sys.sp_executesql @sql;
GO


DROP TABLE IF EXISTS Sales.EmployeeCustomerPivot;

DECLARE @cols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);

SELECT @cols =
    STRING_AGG(QUOTENAME(empid), ',')
FROM
(
    SELECT DISTINCT empid
    FROM Sales.Orders
) AS C;

SET @sql = '
SELECT custid, ' + @cols + '
INTO Sales.EmployeeCustomerPivot
FROM
(
    SELECT empid, custid, FREIGHT
    FROM Sales.Orders
) AS D
PIVOT
(
    SUM(FREIGHT)
    FOR empid IN (' + @cols + ')
) AS P;
';

EXEC sys.sp_executesql @sql;

GO

---می‌توانیم از sys.columns استفاده کنیم:

SELECT name
FROM sys.columns
WHERE object_id = OBJECT_ID('Sales.EmployeeCustomerPivot')
  AND name <> 'custid';
GO

DECLARE @cols NVARCHAR(MAX);

SELECT @cols =
    STRING_AGG(QUOTENAME(name), ',')
FROM sys.columns
WHERE object_id = OBJECT_ID('Sales.EmployeeCustomerPivot')
  AND name <> 'custid';


DECLARE @sql NVARCHAR(MAX);

SET @sql = '
SELECT
    empid,
    custid,
    FREIGHT
FROM Sales.EmployeeCustomerPivot
UNPIVOT
(
    FREIGHT
    FOR empid IN (' + @cols + ')
) AS U;
';

EXEC sys.sp_executesql @sql;

GO

SELECT
    empid,
    custid,
    FREIGHT
FROM Sales.EmployeeCustomerPivot
UNPIVOT
(
    FREIGHT
    FOR empid IN ([1],[2],[3],[4],[5],[6],[7],[8],[9])
) AS U;
GO
SELECT empid, custid, FREIGHT
FROM  Sales.EmployeeCustomerPivot
CROSS APPLY (VALUES('1', [1]), ('2', [2]), ('3', [3]), ('4', [4]), ('5', [5]), ('6', [6]), ('7', [7])
, ('8', [8]), ('9', [9])) AS C(empid, FREIGHT)
WHERE FREIGHT IS NOT NULL;
GO

SELECT
    empid,
    custid,
    SUM(FREIGHT) AS sumFREIGHT
FROM [Sales].[Orders]
GROUP BY
    GROUPING SETS
    (
        (empid, custid),
        (empid),
        (custid),
        ()
    );

GO

SELECT
    empid,
    custid,
    SUM(FREIGHT) AS sumFREIGHT
FROM [Sales].[Orders]

GROUP BY CUBE(empid, custid)
GO
SELECT
    empid,
    custid,
    GROUPING(empid)  AS grpemp,
    GROUPING(custid) AS grpcust,
    SUM(FREIGHT) AS sumFREIGHT
FROM [Sales].[Orders]

GROUP BY CUBE(empid, custid)
GO
SELECT
    YEAR(orderdate) AS ORDERYEAR,
    MONTH(orderdate)AS ORDERMONTH,
    DAY(orderdate) AS ORDERDAY,
    SUM(FREIGHT) AS sumFREIGHT
FROM [Sales].[Orders]

GROUP BY ROLLUP
(
    YEAR(orderdate),
    MONTH(orderdate),
    DAY(orderdate)
);
GO
USE toplearn
GO

DROP TABLE dbo.Employees
GO

CREATE TABLE dbo.Employees
(
    EmpID INT,
    EmpName VARCHAR(50),
    City VARCHAR(50)
);
GO
BULK INSERT dbo.Employees
FROM 'C:\SQLData\Employees.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

GO
DROP TABLE dbo.Orders
CREATE TABLE dbo.Orders
(
    OrderID INT,
    OrderDate DATE,
    EmpID INT,
    CustID INT,
    Freight DECIMAL(10,2)
);
GO

BULK INSERT dbo.Orders
FROM 'C:\SQLData\Orders.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
GO
BULK INSERT dbo.Orders
FROM 'C:\SQLData\Orders2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
GO
CREATE SEQUENCE dbo.SeqOrderIDs
AS INT
MINVALUE 1
CYCLE;
GO
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;
GO
DROP TABLE IF EXISTS dbo.MyOrders;

CREATE TABLE dbo.MyOrders
(
    OrderID   INT NOT NULL PRIMARY KEY,
    CustID    INT NOT NULL,
    Freight   DECIMAL(10,2)
);
GO
DROP SEQUENCE IF EXISTS dbo.SeqOrderIDs;

CREATE SEQUENCE dbo.SeqOrderIDs
AS INT
START WITH 10001
INCREMENT BY 1;
GO
INSERT INTO dbo.MyOrders
    (OrderID, CustID, Freight)
VALUES
    (NEXT VALUE FOR dbo.SeqOrderIDs, 71, 25.50);
GO
INSERT INTO dbo.MyOrders
    (OrderID, CustID, Freight)
VALUES
    (NEXT VALUE FOR dbo.SeqOrderIDs, 42, 15.20),
    (NEXT VALUE FOR dbo.SeqOrderIDs, 37, 81.00);
GO
DROP TABLE IF EXISTS dbo.MyOrders;

CREATE TABLE dbo.MyOrders
(
    OrderID   INT NOT NULL PRIMARY KEY,
    CustID    INT NOT NULL,
    Freight   DECIMAL(10,2)
);
GO

INSERT INTO dbo.MyOrders
    (OrderID, CustID, Freight)
VALUES
    (NEXT VALUE FOR dbo.SeqOrderIDs, 42, 15.20),
    (NEXT VALUE FOR dbo.SeqOrderIDs, 37, 81.00);
GO
DELETE FROM dbo.MyOrders
WHERE custid = 37;
GO
DELETE FROM dbo.MyOrders;
GO
use Northwind
go
DELETE O
FROM dbo.Orders AS O
JOIN dbo.Customers AS C
    ON O.CustomerID = C.CustomerID
WHERE C.Country = 'USA';
go
UPDATE dbo.Orders
SET
    freight = 50,
    shipcountry = 'USA'
WHERE orderid = 10293;
go

UPDATE O
SET O.Freight = O.Freight * 0.90
FROM dbo.Orders AS O
JOIN dbo.Customers AS C
    ON O.CustomerID = C.CustomerID
WHERE C.Country = 'USA';
GO
UPDATE [dbo].[Order Details]
SET discount -= 0.05
WHERE productid = 5;
GO
USE TOPLEARN
GO
DROP TABLE dbo.Customers
GO
-- جدول هدف (Customers)
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(50),
    City NVARCHAR(50),
    Phone NVARCHAR(20)
);

-- جدول منبع (CustomersStage)
CREATE TABLE dbo.CustomersStage (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(50),
    City NVARCHAR(50),
    Phone NVARCHAR(20)
);

-- درج داده در جدول هدف
INSERT INTO dbo.Customers VALUES
(1, 'Ali Rezaei', 'Tehran', '09121112222'),
(2, 'Sara Ahmadi', 'Shiraz', '09123334444'),
(3, 'Mohammad Karimi', 'Isfahan', '09125556666');

-- درج داده در جدول منبع
INSERT INTO dbo.CustomersStage VALUES
(1, 'Ali Rezaei', 'Tehran', '09127778888'),  -- تغییر شماره تلفن
(3, 'Mohammad Karimi', 'Mashhad', '09129990000'), -- تغییر شهر
(4, 'Zahra Mohammadi', 'Tabriz', '09121112233'); -- مشتری جدید
GO

MERGE INTO dbo.Customers AS T
USING dbo.CustomersStage AS S
ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
    UPDATE SET 
        T.CustomerName = S.CustomerName,
        T.City = S.City,
        T.Phone = S.Phone
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Phone)
    VALUES (S.CustomerID, S.CustomerName, S.City, S.Phone)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
GO
MERGE INTO dbo.Customers AS T
USING dbo.CustomersStage AS S
ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
    UPDATE SET T.City = S.City
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Phone)
    VALUES (S.CustomerID, S.CustomerName, S.City, S.Phone)
OUTPUT $action AS Operation,
       inserted.CustomerID AS NewID,
       deleted.CustomerID AS OldID,
       inserted.City AS NewCity,
       deleted.City AS OldCity;
go

MERGE INTO dbo.Customers AS T
USING dbo.CustomersStage AS S
ON T.CustomerID = S.CustomerID
WHEN MATCHED AND (
    T.CustomerName <> S.CustomerName OR
    T.City <> S.City OR
    T.Phone <> S.Phone
) THEN
    UPDATE SET 
        T.CustomerName = S.CustomerName,
        T.City = S.City,
        T.Phone = S.Phone
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Phone)
    VALUES (S.CustomerID, S.CustomerName, S.City, S.Phone);
go

WITH SourceCTE AS (
    SELECT CustomerID, CustomerName, City, Phone
    FROM dbo.CustomersStage
    WHERE City = 'Tehran'
)
MERGE INTO dbo.Customers AS T
USING SourceCTE AS S
ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
    UPDATE SET T.Phone = S.Phone
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Phone)
    VALUES (S.CustomerID, S.CustomerName, S.City, S.Phone);


go
-- ایجاد جدول
DROP TABLE IF EXISTS dbo.Products;
CREATE TABLE dbo.Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2),
    RowNumber INT NULL
);

-- درج داده
INSERT INTO dbo.Products (ProductName, Price)
VALUES ('Laptop', 1000), ('Mouse', 20), ('Keyboard', 50), ('Monitor', 300)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Products P
    WHERE P.ProductName = NewProducts.ProductName
);

-- مشاهده داده‌ها قبل از به‌روزرسانی
SELECT * FROM dbo.Products;

-- به‌روزرسانی با Derived Table (راه‌حل صحیح)
UPDATE P
SET RowNumber = D.RowNum
FROM dbo.Products AS P
INNER JOIN (
    SELECT ProductID, Price,
           ROW_NUMBER() OVER(ORDER BY Price) AS RowNum
    FROM dbo.Products
) AS D ON P.ProductID = D.ProductID;


SELECT *
FROM dbo.Products
ORDER BY RowNumber;

GO
WITH TopProducts AS (
    SELECT TOP 3 *
    FROM dbo.Products
    ORDER BY Price DESC
)
DELETE FROM TopProducts;
GO

WITH NewProducts AS (
    SELECT 'Tablet' AS ProductName, 200 AS Price
    UNION ALL
    SELECT 'Headphone', 30
)
INSERT INTO dbo.Products (ProductName, Price)
SELECT ProductName, Price
FROM NewProducts
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Products P
    WHERE P.ProductName = NewProducts.ProductName
);
GO

-- ایجاد جدول موقت
CREATE TABLE NEWPRODUCT (
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2)
);

-- درج داده‌ها از CSV
BULK INSERT NEWPRODUCT
FROM 'C:\SQLDATA\NEW.CSV'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

-- درج با شرط NOT EXISTS
INSERT INTO dbo.Products (ProductName, Price)
SELECT ProductName, Price
FROM NEWPRODUCT AS T
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Products P
    WHERE P.ProductName = T.ProductName
)
WITH ProductCTE AS (
    SELECT ProductID,
           ROW_NUMBER() OVER(ORDER BY Price) AS RowNum
    FROM dbo.Products
)
UPDATE P
SET RowNumber = D.RowNum
FROM dbo.Products AS P
INNER JOIN ProductCTE AS D ON P.ProductID = D.ProductID;

-- نمایش نتیجه
SELECT * FROM dbo.Products;

-- پاکسازی
DROP TABLE NEWPRODUCT;

GO

-- مرحله ۱: ایجاد جدول موقت برای داده‌های CSV
CREATE TABLE NEWPRODUCT (
    ProductName NVARCHAR(50),
    Price DECIMAL(10,2)
);

-- مرحله ۲: درج داده‌ها از فایل CSV به جدول موقت
BULK INSERT NEWPRODUCT
FROM 'C:\SQLDATA\NEW.CSV'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
 
);

-- مرحله ۳: حذف رکوردهای موجود در جدول اصلی که در CSV هستند
DELETE P
FROM dbo.Products AS P
INNER JOIN NEWPRODUCT AS T
    ON P.ProductName = T.ProductName;
WITH ProductCTE AS (
    SELECT ProductID,
           ROW_NUMBER() OVER(ORDER BY Price) AS RowNum
    FROM dbo.Products
)
UPDATE P
SET RowNumber = D.RowNum
FROM dbo.Products AS P
INNER JOIN ProductCTE AS D ON P.ProductID = D.ProductID;
-- مرحله ۴: نمایش نتیجه
SELECT * FROM dbo.Products;

-- مرحله ۵: پاکسازی (حذف جدول موقت)
DROP TABLE NEWPRODUCT;
GO

-- حذف ۱۰ رکورد گران‌قیمت
WITH ToDelete AS (
    SELECT TOP 2 *
    FROM dbo.Products
    ORDER BY Price DESC
)

DELETE FROM ToDelete;
GO
DROP TABLE dbo.Customers
DROP TABLE dbo.CustomersStage
-- جدول هدف (Target)
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(50),
    City NVARCHAR(50),
    Phone NVARCHAR(20)
);

-- جدول منبع (Source)
CREATE TABLE dbo.CustomersStage (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(50),
    City NVARCHAR(50),
    Phone NVARCHAR(20)
);

-- درج داده در جدول هدف
INSERT INTO dbo.Customers VALUES
(1, 'Ali Rezaei', 'Tehran', '09121112222'),
(2, 'Sara Ahmadi', 'Shiraz', '09123334444');

-- درج داده در جدول منبع
INSERT INTO dbo.CustomersStage VALUES
(1, 'Ali Rezaei', 'Tehran', '09127778888'),   -- تغییر شماره تلفن → UPDATE
(3, 'Mohammad Karimi', 'Mashhad', '09129990000'); -- مشتری جدید → INSERT

GO



MERGE INTO dbo.Customers AS T
USING dbo.CustomersStage AS S
ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
    UPDATE SET 
        T.CustomerName = S.CustomerName,
        T.City = S.City,
        T.Phone = S.Phone
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, City, Phone)
    VALUES (S.CustomerID, S.CustomerName, S.City, S.Phone)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT $action AS Operation,
       inserted.CustomerID AS NewID,
       deleted.CustomerID AS OldID,
       inserted.City AS NewCity,
       deleted.City AS OldCity,
       inserted.Phone AS NewPhone,
       deleted.Phone AS OldPhone;
GO

-- حذف ۳ رکورد گران‌قیمت و بایگانی آن‌ها
DROP TABLE dbo.Products_Archive


CREATE TABLE dbo.Products_Archive (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(50),
    Price INT,
    RowNumber INT,
    DeletedDate DATETIME DEFAULT GETDATE() 
);


DELETE FROM dbo.Products
OUTPUT deleted.ProductID,
       deleted.ProductName,
       deleted.Price,
       deleted.RowNumber
INTO dbo.Products_Archive (ProductID, ProductName, Price, RowNumber)
WHERE ProductID IN (
    SELECT TOP 3 ProductID
    FROM dbo.Products
    ORDER BY Price DESC
);
GO
DECLARE @NewEmployees TABLE (
    EmpID INT,
    EmpName NVARCHAR(50),
    CITY NVARCHAR(50)
);

INSERT INTO dbo.Employees (EmpName, CITY,EmpID)
OUTPUT inserted.EmpID, inserted.EmpName, inserted.CITY
INTO @NewEmployees
VALUES ('Reza', 'TEHRAN', 5);

SELECT * FROM @NewEmployees;

GO
DECLARE @DELEmployees TABLE (
    EmpID INT,
    EmpName NVARCHAR(50),
    CITY NVARCHAR(50),
    DeletedDate DATETIME DEFAULT GETDATE()
);
DELETE FROM dbo.Employees
OUTPUT deleted.EmpID, deleted.EmpName, deleted.CITY
INTO @DELEmployees (EmpID, EmpName, CITY)
WHERE EmpID = 5

SELECT * FROM @DELEmployees;
GO
DECLARE @DELEmployees2 TABLE (
    EmpID INT,
    EmpName NVARCHAR(50),
    CITY NVARCHAR(50),
    DeletedDate DATETIME DEFAULT GETDATE()
);
UPDATE dbo.Employees
SET CITY = 'MASHHAD',
    EmpID+=10
OUTPUT deleted.EmpID AS OLDEMP,
       inserted.EmpID AS NEWEMP,
       deleted.CITY AS OldSalary,
       inserted.CITY AS NewSalary,
       (inserted.EmpID - deleted.EmpID) AS Difference
INTO @DELEmployees2 (deleted.EmpID, EmpName, deleted.CITY)
WHERE EmpID = 1;
GO
DECLARE @DELEmployees2 TABLE (
    OldEmpID     INT,
    NewEmpID     INT,
    OldCity      NVARCHAR(50),
    NewCity      NVARCHAR(50),
    IDDifference INT,
    DeletedDate  DATETIME DEFAULT GETDATE()  
);

UPDATE dbo.Employees
SET CITY = 'MASHHAD',
    EmpID += 10
OUTPUT deleted.EmpID,
       inserted.EmpID,
       deleted.CITY,
       inserted.CITY,
       (inserted.EmpID - deleted.EmpID)
INTO @DELEmployees2 (OldEmpID, NewEmpID, OldCity, NewCity, IDDifference)
WHERE EmpID = 1;

SELECT * FROM @DELEmployees2;
GO

-- جدول هدف
CREATE TABLE dbo.TargetTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50),
    Salary DECIMAL(10,2)
);

-- جدول منبع
CREATE TABLE dbo.SourceTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50),
    Salary DECIMAL(10,2)
);

-- درج داده در جداول
INSERT INTO dbo.TargetTable VALUES (1, 'Ali', 5000), (2, 'Sara', 6000);
INSERT INTO dbo.SourceTable VALUES (1, 'Ali Rezaei', 5500), (3, 'Mohammad', 7000);

GO

MERGE INTO dbo.TargetTable AS T
USING dbo.SourceTable AS S
ON T.ID = S.ID
WHEN MATCHED THEN
    UPDATE SET T.Name = S.Name, T.Salary = S.Salary
WHEN NOT MATCHED THEN
    INSERT (ID, Name, Salary) VALUES (S.ID, S.Name, S.Salary)
OUTPUT $action AS Action,
       inserted.ID AS NewID,
       deleted.ID AS OldID,
       inserted.Name AS NewName,
       deleted.Name AS OldName;

GO

CREATE TABLE dbo.SalaryChanges (
    ID INT,
    OldSalary DECIMAL(10,2),
    NewSalary DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
);


INSERT INTO dbo.SalaryChanges (ID, OldSalary, NewSalary)
SELECT ID, OldSalary, NewSalary
FROM (
    UPDATE dbo.TargetTable
    SET Salary = Salary * 1.05
    OUTPUT inserted.ID,
           deleted.Salary AS OldSalary,
           inserted.Salary AS NewSalary
    WHERE Salary < 6000
) AS Changes;
SELECT * FROM dbo.SalaryChanges
SELECT * FROM DBO.TargetTable
GO

DROP TABLE IF EXISTS dbo.ProductsAudit;
DROP TABLE IF EXISTS dbo.Products;
GO

CREATE TABLE dbo.Products
(
    productid     INT NOT NULL PRIMARY KEY,
    productname   NVARCHAR(40) NOT NULL,
    supplierid    INT NOT NULL,
    unitprice     MONEY NOT NULL CONSTRAINT DFT_Products_unitprice DEFAULT(0),
    CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

CREATE TABLE dbo.ProductsAudit
(
    LSN        INT NOT NULL IDENTITY PRIMARY KEY,
    TS         DATETIME2 NOT NULL DEFAULT(SYSDATETIME()),
    productid  INT NOT NULL,
    colname    SYSNAME NOT NULL,
    oldval     SQL_VARIANT NOT NULL,
    newval     SQL_VARIANT NOT NULL
);
GO


INSERT INTO dbo.Products (productid, productname, supplierid, unitprice)
VALUES
    (1, N'Product A', 1, 18.00),   -- supplierid=1, قیمت قدیم <20 → جدید=20.70 → باید Audit شود ✅
    (2, N'Product B', 1, 19.00),   -- supplierid=1, قیمت قدیم <20 → جدید=21.85 → باید Audit شود ✅
    (3, N'Product C', 1, 25.00),   -- supplierid=1, قیمت قدیم از اول >=20 → نباید Audit شود ❌
    (4, N'Product D', 1, 10.00),   -- supplierid=1, حتی بعد از افزایش هم <20 می‌ماند → نباید Audit شود ❌
    (5, N'Product E', 2, 18.00);   -- supplierid متفاوت (2) → اصلاً توسط UPDATE لمس نمی‌شود


SELECT * FROM dbo.Products;
GO
--  افزایش ۱۵٪ قیمت برای تأمین‌کنندهٔ ۱،
-- ولی فقط محصولاتی که قیمت قبلی < 20 بوده و قیمت جدید >= 20 شده را Audit کن
INSERT INTO dbo.ProductsAudit(productid, colname, oldval, newval)
SELECT productid, N'unitprice', oldval, newval
FROM (
    UPDATE dbo.Products
    SET unitprice *= 1.15
    OUTPUT
        inserted.productid,
        deleted.unitprice  AS oldval,
        inserted.unitprice AS newval
    WHERE supplierid = 1
) AS D
WHERE oldval < 20.0 AND newval >= 20.0;


SELECT * FROM dbo.ProductsAudit;
use toplearn
go
create database practice
go
use practice
go
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS  dbo.Employees
GO
CREATE TABLE dbo.Employees
(
    EmpID INT NOT NULL,
    EmpName VARCHAR(50) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Employees
        PRIMARY KEY(EmpID),

    CONSTRAINT CK_Employees_Salary
        CHECK (Salary >= 0)
);
go
INSERT INTO dbo.Employees
    (EmpID, EmpName, Department, Salary)
VALUES
    (1, 'Ali',  'IT',      60000),
    (2, 'Reza', 'Finance', 75000),
    (3, 'Sara', 'IT',      80000),
    (4, 'Mina', 'Sales',   50000);
go
SELECT
    EmpID,
    EmpName,
    Salary
FROM dbo.Employees
WHERE Salary >= 70000
ORDER BY Salary DESC;
go
CREATE TABLE dbo.Customers
(
    CustID INT NOT NULL,
    CustName VARCHAR(50) NOT NULL,
    City VARCHAR(50) NULL,

    CONSTRAINT PK_Customers
        PRIMARY KEY(CustID)
);
go
INSERT INTO dbo.Customers
    (CustID, CustName, City)
VALUES
    (1, 'Ali Co',  'Tehran'),
    (2, 'Sara Co', 'Tabriz'),
    (3, 'Reza Co', NULL);

go

CREATE TABLE dbo.Orders
(
    OrderID INT NOT NULL,
    CustID INT NOT NULL,
    OrderDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Orders
        PRIMARY KEY(OrderID),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY(CustID)
        REFERENCES dbo.Customers(CustID),

    CONSTRAINT CK_Orders_Amount
        CHECK (Amount >= 0)
);
GO

INSERT INTO dbo.Orders
    (OrderID, CustID, OrderDate, Amount)
VALUES
    (101, 1, '2026-09-01', 1000),
    (102, 1, '2026-09-02', 2000),
    (103, 2, '2026-09-03', 1500);
GO

SELECT
    C.CustID,
    C.CustName,
    O.OrderID,
    O.Amount
FROM dbo.Customers AS C
INNER JOIN dbo.Orders AS O
    ON C.CustID = O.CustID;
GO
SELECT
    C.CustID,
    C.CustName,
    A.OrderID,
    A.Amount
   
FROM dbo.Customers AS C
CROSS APPLY (SELECT O.ORDERID , O.CustID , O.Amount FROM dbo.Orders AS O
 WHERE O.AMOUNT>=1500 AND C.CustID = O.CustID ) AS A
 GO



 SELECT
    C.CustID,
    C.CustName,
    A.OrderID,
    A.Amount
FROM dbo.Customers AS C
OUTER APPLY (
    SELECT O.OrderID, O.CustID, O.Amount 
    FROM dbo.Orders AS O
    WHERE O.Amount >= 1500 
      AND C.CustID = O.CustID
) AS A;
GO
DROP TABLE IF EXISTS dbo.Sales;

CREATE TABLE dbo.Sales
(
    SaleID INT NOT NULL,
    EmpID INT NOT NULL,
    SaleDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) NULL
        CONSTRAINT DFT_Sales_Discount DEFAULT(0),

    CONSTRAINT PK_Sales
        PRIMARY KEY(SaleID),

    CONSTRAINT CK_Sales_Amount
        CHECK (Amount >= 0),

    CONSTRAINT CK_Sales_Discount
        CHECK (Discount >= 0 AND Discount <= 100)
);
GO
INSERT INTO dbo.Sales
    (SaleID, EmpID, SaleDate, Amount)
VALUES
    (1, 1, '2026-09-01', 1000),
    (2, 1, '2026-09-02', 2000),
    (3, 2, '2026-09-03', 3000);


GO
SELECT
    EmpID,
    COUNT(*) AS NumberOfSales,
    SUM(Amount) AS TotalSales,
    CASE
        WHEN SUM(Amount) >= 2500 THEN 'High'
        ELSE 'Low'
    END AS SalesLevel
FROM dbo.Sales
GROUP BY EmpID;
GO
CREATE TABLE dbo.OrderDetails
(
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Qty INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_OrderDetails
        PRIMARY KEY(OrderID, ProductID),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY(OrderID)
        REFERENCES dbo.Orders(OrderID),

    CONSTRAINT CK_OrderDetails_Qty
        CHECK(Qty > 0),

    CONSTRAINT CK_OrderDetails_UnitPrice
        CHECK(UnitPrice >= 0)
);
GO

INSERT INTO dbo.OrderDetails
VALUES
    (101, 10, 2, 500),
    (101, 20, 3, 200),
    (102, 10, 1, 500);
    GO
    SELECT
    O.OrderID,
    O.OrderDate,
    OD.ProductID,
    OD.Qty,
    OD.UnitPrice,
    OD.Qty * OD.UnitPrice AS TotalValue
FROM dbo.Orders AS O
INNER JOIN dbo.OrderDetails AS OD
    ON O.OrderID = OD.OrderID;
    GO
    SELECT
    O.OrderID,
    O.OrderDate,
    A.ProductID,
    A.Qty,
    A.UnitPrice,
    A.TotalValue
FROM dbo.Orders AS O
OUTER APPLY (SELECT OD.OrderID ,OD.ProductID, OD.Qty,
    OD.UnitPrice , OD.Qty * OD.UnitPrice AS TotalValue
    FROM dbo.OrderDetails AS OD
    WHERE O.OrderID = OD.OrderID AND OD.Qty * OD.UnitPrice > 500) AS A
    GO
USE toplearn_db
GO
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Employees;
GO

CREATE TABLE dbo.Employees
(
    EmpID INT NOT NULL,
    EmpName VARCHAR(50) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Employees
        PRIMARY KEY(EmpID),

    CONSTRAINT CK_Employees_Salary
        CHECK(Salary >= 0),

    CONSTRAINT UQ_Employees_EmpName
        UNIQUE(EmpName)
);
GO
INSERT INTO dbo.Employees
VALUES
    (1, 'Ali',  'IT',      60000),
    (2, 'Sara', 'Finance', 80000),
    (3, 'Reza', 'IT',      70000),
    (4, 'Mina', 'Sales',   50000);
GO
CREATE TABLE dbo.Orders
(
    OrderID INT NOT NULL,
    EmpID INT NOT NULL,
    OrderDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL
        CONSTRAINT DFT_Orders_Amount DEFAULT(0),

    CONSTRAINT PK_Orders
        PRIMARY KEY(OrderID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY(EmpID)
        REFERENCES dbo.Employees(EmpID),

    CONSTRAINT CK_Orders_Amount
        CHECK(Amount >= 0)
);
GO
INSERT INTO dbo.Orders
    (OrderID, EmpID, OrderDate, Amount)
VALUES
    (101, 1, '2026-01-10', 1000),
    (102, 1, '2026-01-15', 2000),
    (103, 2, '2026-01-20', 5000),
    (104, 3, '2026-01-25', 3000),
    (105, 3, '2026-02-01', 4000);
GO
SELECT
    E.EmpID,
    E.EmpName,
    E.Department,
    COUNT(O.OrderID) AS NumberOfOrders,
    SUM(O.Amount) AS TotalSales
FROM dbo.Employees AS E
INNER JOIN dbo.Orders AS O
    ON E.EmpID = O.EmpID
GROUP BY
    E.EmpID,
    E.EmpName,
    E.Department;

GO
SELECT
    E.EmpID,
    E.EmpName,
    E.Department,
    A.NumberOfOrders,
    A.TotalSales
FROM dbo.Employees AS E
CROSS APPLY (SELECT O.EmpID ,COUNT(O.OrderID) AS NumberOfOrders,
    SUM(O.Amount) AS TotalSales FROM  dbo.Orders AS O
    WHERE E.EmpID = O.EmpID 
    GROUP BY O.EmpID)AS A
WHERE A.TotalSales > 4000
GO
SELECT
    E.EmpID,
    E.EmpName,
    E.Department,
    SUM(O.Amount) AS TotalSales
FROM dbo.Employees AS E
INNER JOIN dbo.Orders AS O
    ON E.EmpID = O.EmpID
GROUP BY
    E.EmpID,
    E.EmpName,
    E.Department
HAVING SUM(O.Amount) > 4000;
GO


SELECT
    E.EmpID,
    E.EmpName,
    E.Department,
    O.OrderID,
    O.Amount,
    SUM(O.Amount) OVER(
        PARTITION BY E.EmpID
    ) AS TotalSales
FROM dbo.Employees AS E
INNER JOIN dbo.Orders AS O
    ON E.EmpID = O.EmpID;

go
use TSQLV4
go

SELECT name, object_id
FROM sys.tables
WHERE name = 'Employees';
go
SELECT 
    name,
    column_id,
    system_type_id
FROM sys.columns
WHERE object_id = OBJECT_ID('HR.Employees');
GO
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length
FROM sys.columns AS c
JOIN sys.types AS t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('HR.Employees');
GO
SELECT 
    name,
    type,
    type_desc
FROM sys.objects;
SELECT 
    i.name AS IndexName,
    c.name AS ColumnName
FROM sys.indexes AS i
JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
JOIN sys.columns AS c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('HR.Employees')
 AND i.name = 'IX_Employees_City_Salary';
GO
SELECT 
    name,
    database_id,
    state_desc
FROM sys.databases;
GO
SELECT 
    name,
    schema_id
FROM sys.schemas;
GO
SELECT 
    name,
    object_id
FROM sys.views;
GO
SELECT 
    name,
    object_id
FROM sys.procedures;
GO
SELECT 
    name,
    parent_id
FROM sys.triggers;
GO
SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length
FROM sys.tables AS t
JOIN sys.columns AS c
    ON t.object_id = c.object_id
JOIN sys.types AS ty
    ON c.user_type_id = ty.user_type_id
WHERE t.name = 'Employees';
GO



