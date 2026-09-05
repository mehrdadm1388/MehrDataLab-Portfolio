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

      