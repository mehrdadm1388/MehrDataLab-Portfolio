use TSQLV4
go
 SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;  
go

SELECT orderid
FROM Sales.Orders
WHERE empid =
    (SELECT E.empid
     FROM HR.Employees AS E
     WHERE E.lastname LIKE N'D%')
     
go

 SELECT name, create_date
    FROM sys.tables
    WHERE name LIKE 'Orders%';
go
CREATE PROCEDURE UpdateProductPrice
    @productid INT,             
    @NewPrice DECIMAL(10,2)  
AS
BEGIN
    UPDATE [Production].[Products]          
    SET unitprice = @NewPrice    
    WHERE productid = @productid; 
END;
GO

EXEC UpdateProductPrice @productid = 5, @NewPrice = 15;
go

WITH C AS
(
    SELECT *, YEAR(orderdate) AS order_year
    FROM Sales.Orders
)
SELECT order_year, COUNT(*) as co
FROM C
GROUP BY order_year;

go 
SELECT YEAR(orderdate) AS order_year, COUNT(*) as co
FROM Sales.Orders
GROUP BY YEAR(orderdate);

go

SELECT O.orderid, O.custid
FROM Sales.Orders AS O
WHERE O.freight >
(
    SELECT AVG(O2.freight)
    FROM Sales.Orders AS O2
);
go
with empscte as
(select empid,
        mgrid,
        lastname
 from [HR].[Employees]
 where empid=2
  union all

 select c.empid,
        c.mgrid,
        c.lastname
 FROM empscte p 
 inner join [HR].[Employees] c
 on c.mgrid=p.empid
 )
 select empid,
        mgrid,
        lastname
 from empscte
 GO

 ALTER VIEW [Sales].[OrderValues]
  WITH ENCRYPTION
AS

SELECT O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate;
GO

 ALTER VIEW [Sales].[OrderValues]
  WITH SCHEMABINDING
AS

SELECT O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate,
  SUM(OD.qty) AS qty,
  CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))
       AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
  JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
GROUP BY O.orderid, O.custid, O.empid, O.shipperid, O.orderdate, O.requireddate, O.shippeddate;
GO

select c.custid, a.orderid,a.orderdate
from sales.Customers as c
  cross apply
  (select top (3) orderid,orderdate,requireddate
  from sales.orders as o
  where o.custid = c.custid
  order by orderdate desc , orderid desc) as a

go

create function dbo.toporder
(@custid as int , @r as int)
returns table
as 
return
  select top (@r) orderid,orderdate,requireddate
  from sales.orders 
  where custid = @custid
  order by orderdate desc, orderid desc
go
select c.custid, a.orderid,a.orderdate
from sales.Customers as c
  cross apply dbo.toporder(c.custid,3) as a

go

SELECT 
    orderid,
    custid,
    orderdate,
    freight,
    
    sum(freight) OVER (
        PARTITION BY custid 
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS last_amount,
    
    LAST_VALUE(freight) OVER (
        PARTITION BY custid 
        ORDER BY orderdate
        ROWS BETWEEN current row AND 2 FOLLOWING
    ) AS last_amount2,

    LAST_VALUE(freight) OVER (
        PARTITION BY custid 
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND 3 FOLLOWING
    ) AS last_amount3

FROM sales.Orders;
go
SELECT empid, ordermonth, val,
       SUM(val) OVER (ORDER BY ordermonth
                      ROWS BETWEEN UNBOUNDED PRECEDING
                              AND CURRENT ROW) AS runval_total
FROM Sales.EmpOrders;
go
WITH OrderSales AS (
    SELECT empid, ordermonth, val,
           SUM(val) OVER(PARTITION BY empid ORDER BY ordermonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
    FROM Sales.EmpOrders
)
SELECT empid, ordermonth, val, running_total
FROM OrderSales
WHERE running_total > 1000; -- حالا running_total قابل استفاده است.
go
SELECT 
    orderid,
    empid,
    custid,
    orderdate,
    freight,
    
    SUM(freight) OVER (
        PARTITION BY empid 
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND current row
    ) AS first_amount  /*, 
    
     SUM(freight) OVER (
        PARTITION BY custid 
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND 2 FOLLOWING
    ) AS last_amount2,

    SUM(freight) OVER (
        PARTITION BY custid 
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND 3 FOLLOWING

    ) AS last_amount3,

    SUM(freight) OVER () as total,
    SUM(freight) OVER (PARTITION BY custid) as totalcust
    */

FROM sales.Orders;
go
CREATE TABLE DBO.CUSTIMP
( custid INT NOT NULL
         CONSTRAINT PK_CUSTIMP PRIMARY KEY,
         [1] VARCHAR(10) NULL,
         [2] VARCHAR(10) NULL,
         [3] VARCHAR(10) NULL,
         [4] VARCHAR(10) NULL,
         [5] VARCHAR(10) NULL,
         [6] VARCHAR(10) NULL,
         [7] VARCHAR(10) NULL,
         [8] VARCHAR(10) NULL,
         [9] VARCHAR(10) NULL)

INSERT INTO DBO.CUSTIMP(custid, [1], [2], [3], [4], [5], [6], [7], [8], [9])
SELECT 
    custid, [1], [2], [3], [4], [5], [6], [7], [8], [9]
FROM (
    SELECT 
        empid,
        custid,
        freight
    FROM sales.Orders
) AS O
PIVOT(
    SUM(freight) 
    FOR empid IN ([1], [2], [3], [4], [5], [6], [7], [8], [9])
) AS P;

go
SELECT * FROM DBO.CUSTIMP
GO
SELECT 
    custid,
    CAST(empid AS INT) AS empid,
    fre
FROM CUSTIMP
UNPIVOT (fre FOR empid IN ([1], [2], [3], [4], [5], [6], [7], [8], [9])) AS C;
GO
DECLARE @fieldStr NVARCHAR(200);

SELECT 
    @fieldStr = STRING_AGG('[' + CAST(CustId AS VARCHAR(10)) + ']', ',') 
                WITHIN GROUP (ORDER BY CustId ASC)
FROM (SELECT DISTINCT CustId FROM SALES.Orders) AS D;
PRINT @fieldStr

DECLARE @Sql NVARCHAR(MAX) = 
'SELECT empid, ' + @fieldStr + '
FROM
    (SELECT empid, custid, freight
     FROM SALES.Orders) AS D
PIVOT(SUM(freight) FOR custid IN (' + @fieldStr + ')) AS p;';

PRINT @Sql;
EXEC(@Sql);

go
DECLARE @fieldStr NVARCHAR(200);
      SELECT  @fieldStr = STRING_AGG('[' + CAST(CustId AS VARCHAR(10)) + ']', ',') 
                
FROM (SELECT DISTINCT CustId FROM SALES.Orders) AS D;
PRINT @fieldStr
GO
DECLARE @X INT = 100;  

DECLARE @sql NVARCHAR(20) =  

    'SELECT ' + CAST(@X AS VARCHAR(20)) + ' AS Number;'  ; 

 PRINT @sql;  

GO
DECLARE @name  NVARCHAR( 100)= 'Ali'

DECLARE @Sql NVARCHAR(MAX)  =

'SELECT '+@name + ' AS Student;  '

PRINT @Sql;

EXEC(@Sql);

GO
DECLARE @Sql NVARCHAR(MAX);

SET @Sql = 'SELECT 10 + 20 AS Result';
PRINT @Sql;

go
DECLARE @Sql NVARCHAR(MAX);

SET @Sql = 'SELECT 10 + 20 AS Result';

SELECT @Sql;

PRINT @Sql;

EXEC(@Sql);
go 

DECLARE @fieldStr NVARCHAR(100) = '[10],[20],[30]';

DECLARE @Sql NVARCHAR(MAX) =
'SELECT empid, ' + @fieldStr + '
FROM SALES.Orders
WHERE empid = 5;';

PRINT @Sql;

go



USE Northwind
GO
SELECT * FROM Employees AS E
WHERE CONTAINS (E.ADDRESS,'"Winchester" OR "Way"')
GO

SELECT PRODUCTNAME , SUM(QUANTITY) AS TOTALQUAN
FROM [dbo].[Order Details] AS O 
INNER JOIN [dbo].[Products] AS P ON P.PRODUCTID = O.PRODUCTID
WHERE O.OrderID = 10287
GROUP BY P.ProductName
GO

SELECT TOP (1) OrderID, Quantity
FROM [dbo].[Order Details] AS O 
WHERE ProductID = 60
ORDER BY Quantity DESC ;
GO
SELECT OrderID, Quantity,drnk,rnk
FROM (
    SELECT 
        OrderID, 
        Quantity,
        DENSE_RANK() OVER (ORDER BY Quantity DESC) AS drnk,
        RANK() OVER (ORDER BY Quantity DESC) AS rnk
    FROM [dbo].[Order Details]
    WHERE ProductID = 60
) AS T
---WHERE rnk = 1;

GO

;WITH OrderTotals AS
(
    -- مرحله ۱: مبلغ کل هر سفارش را محاسبه می‌کنیم
    SELECT 
        OrderID,
        SUM(Quantity * UnitPrice) AS OrderTotalAmount
    FROM [dbo].[Order Details]
    GROUP BY OrderID
),
RankedOrders AS
(
    -- مرحله ۲: سفارش‌ها را بر اساس مبلغ کل رتبه‌بندی می‌کنیم
    SELECT 
        OrderID,
        OrderTotalAmount,
        RANK() OVER (ORDER BY OrderTotalAmount DESC) AS OrderRank
    FROM OrderTotals
)
-- مرحله ۳: جزئیات کالاهای همان سفارش برنده را واکشی می‌کنیم
SELECT 
    OD.OrderID,
    P.ProductName,
    OD.Quantity,
    OD.UnitPrice,
    (OD.Quantity * OD.UnitPrice) AS LineAmount,
    RO.OrderTotalAmount
FROM [dbo].[Order Details] AS OD
JOIN dbo.Products AS P 
    ON OD.ProductID = P.ProductID
JOIN RankedOrders AS RO 
    ON OD.OrderID = RO.OrderID
WHERE RO.OrderRank = 1
ORDER BY LineAmount DESC;
GO

;WITH OD_WithTotal AS
(
  
    SELECT 
        OD.OrderID,
        P.ProductName,
        OD.Quantity,
        OD.UnitPrice,
        OD.Quantity * OD.UnitPrice AS LineAmount,
        SUM(OD.Quantity * OD.UnitPrice) OVER (PARTITION BY OD.OrderID) AS OrderTotalAmount
    FROM [dbo].[Order Details] AS OD
    JOIN dbo.Products AS P 
        ON OD.ProductID = P.ProductID
),
OD_Ranked AS
(
    SELECT 
        *,
        RANK() OVER (ORDER BY OrderTotalAmount DESC) AS OrderRank
    FROM OD_WithTotal
)
SELECT OrderID, ProductName, Quantity, UnitPrice, LineAmount, OrderTotalAmount
FROM OD_Ranked
WHERE OrderRank = 1
ORDER BY LineAmount DESC;
go

SELECT OrderID,ProductID,SUM(UNITPRICE*QUANTITY)AS TOTALPRICE
FROM DBO.[Order Details] 
GROUP BY
GROUPING SETS (
           (OrderID,ProductID),
           (OrderID),(ProductID)
           ,())

GO
SELECT OrderID,ProductID,SUM(UNITPRICE*QUANTITY)AS TOTALPRICE
FROM DBO.[Order Details] 
GROUP BY
GROUPING SETS (
           (OrderID,ProductID),
           (OrderID),(ProductID)
           ,())

GO
SELECT OrderID,ProductID,SUM(UNITPRICE*QUANTITY)AS TOTALPRICE
FROM DBO.[Order Details] 
GROUP BY CUBE (OrderID,ProductID)
GO
SELECT OrderID , CustomerID , EmployeeID, SUM(FREIGHT)AS TOTALFREI
FROM [dbo].[Orders]
GROUP BY CUBE (OrderID,CustomerID , EmployeeID)
GO
SELECT 
       YEAR (ORDERDATE) AS ORDERYEAR,
       MONTH (ORDERDATE)AS ORDERMONTH,
       DAY(ORDERDATE)AS ORDERDAY,
       SUM(FREIGHT)AS TOTALFREI
FROM [dbo].[Orders]
GROUP BY ROLLUP(YEAR (ORDERDATE),
       MONTH (ORDERDATE),
       DAY(ORDERDATE))
GO
USE TSQLV4
GO

CREATE FUNCTION Dbo.GetAge
(
@birthdate as date ,
@eventdate as date
)
returnS int
as 
begin
     RETURN
     DATEDIFF(YEAR , @birthdate ,@eventdate)
     -CASE WHEN 100*MONTH(@eventdate)+DAY(@eventdate)
              < 100*MONTH(@birthdate)+DAY(@birthdate)
              THEN 1 ELSE 0
              END
end

GO

select empid,firstname,lastname,birthdate,
Dbo.GetAge(birthdate,'20260412')AS AGE

FROM HR.Employees
ORDER BY AGE
GO
CREATE PROC DBO.CUSTOMERORDERS
@CUSTID AS INT, 
@FROMDATE AS DATETIME='19900101',
@todate as datetime='99990101',
@numrows as int output
as
set nocount on

select orderid , custid , orderdate
from sales.Orders 
where custid = @CUSTID and
orderdate >= @fromdate
and orderdate<@todate

set @numrows=@@ROWCOUNT
go

declare @x as int
exec DBO.CUSTOMERORDERS
@custid = 5 ,
@fromdate = '20150101',
@todate = '20160101',
@numrows = @x output
go
select @x as numrows 
go
BEGIN TRAN;

-- Declare a variable
DECLARE @neworderid AS INT;

-- Insert a new order into the Sales.Orders table
INSERT INTO Sales.Orders
    (custid, empid, orderdate, requireddate, shippeddate,
     shipperid, freight, shipname, shipaddress, shipcity,
     shippostalcode, shipcountry)
VALUES
    (85, 5, '20160212', '20160301', '20160216',
     3, 32.38, N'Ship to 85-B', N'6789 rue de l''Abbaye', N'Reims',
     N'10345', N'France');

-- Save the new order ID in a variable
SET @neworderid = SCOPE_IDENTITY();

-- Return the new order ID
SELECT @neworderid AS neworderid;


INSERT INTO Sales.OrderDetails
    (orderid, productid, unitprice, qty, discount)
VALUES
    (@neworderid, 11, 14.00, 12, 0.000),
    (@neworderid, 42, 9.80, 10, 0.000),
    (@neworderid, 72, 34.80, 5, 0.000);

-- Commit the transaction
COMMIT TRAN;
go

use toplearn
go


CREATE TABLE Students
(
    StudentID INT PRIMARY KEY,
    StudentName NVARCHAR(50),
    Score INT
);

go
drop TABLE StudentLog
go
create trigger StudentLog on Students after insert
as
set nocount on

CREATE TABLE StudentLog
(
    StudentID INT,
    StudentName NVARCHAR(50),
    LogDate DATETIME
);
go

INSERT INTO Students
VALUES (1, N'Ali', 18);
go
SELECT *
FROM StudentLog;

go

-- آیا Trigger وجود دارد؟
SELECT name FROM sys.triggers WHERE name = 'StudentLog';

-- آیا جدول StudentLog وجود دارد؟
SELECT name FROM sys.tables WHERE name = 'StudentLog';

-- محتوای فعلی Students
SELECT * FROM Students;

go

DROP TRIGGER IF EXISTS StudentLog;
GO
DROP TABLE IF EXISTS StudentLog;
GO
-- 1) جدول اصلی
CREATE TABLE Students
(
    StudentID   INT PRIMARY KEY,
    StudentName NVARCHAR(50),
    Score       INT
);
GO

-- 2) جدول لاگ — یک‌بار و خارج از Trigger ساخته می‌شود

CREATE TABLE StudentLog
(
    StudentID   INT,
    StudentName NVARCHAR(50),
    LogDate     DATETIME
);
GO

-- 3) Trigger فقط INSERT می‌کند، نه CREATE TABLE
CREATE TRIGGER trg_StudentLog
ON Students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO StudentLog (StudentID, StudentName, LogDate)
    SELECT StudentID, StudentName, GETDATE()
    FROM inserted;
END
GO

-- 4) تست
INSERT INTO Students VALUES (1, N'Ali', 18);
GO

SELECT * FROM StudentLog;
go