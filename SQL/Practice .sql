use toplearn

create table Dbo.information(
ID  int   not null,
Fname nvarchar(30)  not null,
lname nvarchar(30)  not null,
country nvarchar(100)  null,
)
go


insert into [dbo].[information](
ID,
fname,
lname,
country
)values (2 , 'mehdi' , 'M','Iran'),(3 , 'farhad' , 'h','Iran')

go

delete from [dbo].[information]
where ID=3

go

delete from [dbo].[information]
where Fname='mehdi'

go

drop table [dbo].[information]
go
use toplearn_db
go
truncate table [dbo].[Information]

go

insert into  [dbo].[Information](
ID,
fname,
lname,
city
) values(1 , 'mehrdad','m','tehran'),
(2,'kamran','f','arak'),
(3,'sara','m','tehran')

go

select city ,* 
from [dbo].[Information]

go

select top(2) Fname,city 
from [dbo].[Information]

go 

update [dbo].[Information]
set city='karaj' , lname='farahani'
where id=2

go

use toplearn
alter database [toplearn] add filegroup fg1

go

select *  from sys.filegroups 

go

alter database [toplearn] add file(
name='personal',
filename = 'C:\filegroupssms\personal.ndf'
) to filegroup fg1

go

use [MehrDataLab]

go

select *  from [dbo].[Students]

-- INNER JOIN
SELECT c.CustomerName, o.OrderDate
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID;

go
USE MehrDataLab_Retail;
GO

SELECT @@SERVERNAME;
go

SELECT SERVERPROPERTY('InstanceName') AS InstanceName;

use [toplearn]
go

alter table [dbo].[personal]
alter column [FirstName]  nvarchar(50) collate Albanian_BIN
go 
select * from ::fn_helpcollations()
go

alter table [dbo].[personal]
add city nvarchar(50) null

go
alter table [dbo].[personal]
add constraint df_city
default  'TEHRAN' for city
go

alter table [dbo].[personal]
alter column [Mobail] int sparse null
go

create view Vw_personal
as
select [id],[FirstName],[city]
from [dbo].[personal]

create or alter view [dbo].[Vw_personal](
[FirstName],
[Mobail],
[city]
)
as
select [FirstName],[Mobail],[city]
from [dbo].[personal]
go 

use toplearn
go
create table Dbo.country(
ID  int   not null,
country nvarchar(100)  null,
)
go
insert into [dbo].[country](
ID,
country
)values(1 , 'Iran') ,(2 , 'canada'),(3 ,'turkey')
go

CREATE OR ALTER VIEW dbo.Vw_personal2
WITH SCHEMABINDING
AS
SELECT id,
    FirstName
    
FROM dbo.personal;

GO

create or alter view dbo.Vw_personal3
with encryption
as
select * from dbo.personal
where id>=2
with check option
go

select * from personal p
order by p.FirstName desc

go

alter table personal
add check (len(firstname) >=3 and len(firstname)<=20)

go
alter table personal
drop constraint if exists [CK__personal__FirstN__72C60C4A]
go

use [TSQLV4]
go

select c.custid , c.companyname ,
o.orderid ,
od.qty , od.productid
from[Sales].[Customers]  as c,
 [Sales].[OrderDetails]as od ,
[Sales].[Orders]as o
go 

select c.custid , c.companyname ,
o.orderid ,
od.qty , od.productid
from Sales.Customers  as c inner join Sales.Orders as o
on c.custid=o.custid
inner join Sales.OrderDetails as od  
on od.orderid=o.orderid and od.productid=11;
go

SELECT
    c.custid,
    c.companyname,
    o.orderid,
    od.qty,
    od.productid
FROM Sales.Customers AS c
INNER JOIN Sales.Orders AS o
    ON c.custid = o.custid
INNER JOIN Sales.OrderDetails AS od
    ON od.orderid = o.orderid
WHERE od.productid = 11;
go

select c.custid , c.companyname ,
o.orderid ,
od.qty , od.productid
from Sales.Customers  as c inner join Sales.Orders as o
on c.custid=o.custid
inner join Sales.OrderDetails as od  
on od.orderid=o.orderid 
where od.productid=11;
go
select * from [Sales].[Orders]
select * from [Sales].[Customers]
select * from [Sales].[OrderDetails]
go
use toplearn
go

set identity_insert personal on
insert personal ([id],[c_id],[FirstName],[LastName],[Mobail],[city])
   values(4,1,'akbar','t',1357,'tabriz')
set identity_insert personal off
go
insert personal ([c_id],[FirstName],[LastName],[Mobail],[city])
   values(1,'abas','f',1357,'arak')
go

use TSQLV4
go

with toplern_cte as(

select * from [Production].[Categories] cross join [HR].[Employees]

)
select * from toplern_cte

go

select * from [HR].[Employees] e
order by e.hiredate 
offset  3 rows
fetch next 5 rows only

go
select * from [HR].[Employees] e
where e.empid between 3 and 6
go
select * from [HR].[Employees] e
where e.firstname like '%s%'

go

select * from [HR].[Employees] e
where e.firstname like '__s%'

go 

select * from [HR].[Employees] e
where e.firstname like 'p%a'
go

use TSQLV4
go

SELECT 
    e.empid,
    e.lastname,
    e.birthdate,
    CASE
        WHEN e.birthdate <= '1970-01-01' THEN 'aged'
        WHEN e.birthdate > '1970-01-01' 
             AND e.birthdate <= '1990-01-01' THEN 'Middle-aged'
        WHEN e.birthdate > '1990-01-01' THEN 'Young'
        ELSE 'error in birthdate'
    END AS AgeGroup
FROM [HR].[Employees] AS e;
go


use toplearn_db
go


create nonclustered columnstore index csi on [dbo].[Information](fname,lname)
go

use toplearn
go

select *

from [dbo].[personal] p

where p.id not in (select id from [toplearn_db].[dbo].Information)
go

use toplearn
go

create schema sls 
go

alter schema sls transfer country
go

alter schema dbo transfer sls.country
go

select * from[dbo].[country] c
where exists (select * from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')

go

SELECT *
FROM [dbo].[country] AS c
WHERE EXISTS
(
    SELECT *
    FROM [dbo].[personal] AS p
    WHERE c.ID = p.id
      AND p.FirstName LIKE 'm%'
);
go

create user atoosa without login
go

alter role [db_datareader]add member atoosa
go

execute as user = 'atoosa'
go

revert
go

select * from[dbo].[country] c
where c.ID = any (select p.id from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')

go 

select * from[dbo].[country] c
where c.ID = all (select p.id from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')
go

create sequence mehrseq
increment by 3
minvalue 10
maxvalue 3000
cycle
go


create table tet_seq(
id int primary key not null ,
lfamily  nvarchar (20) not null)
go

alter table tet_seq
add default next value for mehrseq for id
go

insert into tet_seq(lfamily)
values (N'mo'),(N'fa')

go


use AdventureWorks2019
go

declare @maxid as int= (select max (SalesOrderID) from [Sales].[SalesOrderDetail])

select ShipDate , SalesOrderNumber , ShipToAddressID from [Sales].[SalesOrderHeader] s
where s.SalesOrderID=@maxid
go

select ShipDate , SalesOrderNumber , ShipToAddressID from [Sales].[SalesOrderHeader] s
where s.SalesOrderID=(select max (SalesOrderID) from [Sales].[SalesOrderDetail])
go

use TSQLV4
go
---اینجا بنویسی مساوی مستعد تولید باگه---
select orderid
from sales.orders  o
where empid in ( select e.empid from [HR].[Employees] e 
where lastname like N'D%')
go

---اونجاهایی که not in دارید یا به left join تبدیل کنید یا از not exists استفاده کنید-----
------------------------------------------------------------------------------------------
select city from hr.Employees
union
select city from sales.Customers


select city from hr.Employees
union all
select city from sales.Customers

go

select city from hr.Employees
intersect
select city from sales.Customers


select city from hr.Employees
except
select city from sales.Customers
go

SELECT DB_NAME() AS CurrentDatabase;

SELECT name
FROM sys.databases;
go

USE master;
GO

SELECT name
FROM sys.databases
ORDER BY name;
go

USE master;
GO

SELECT name
FROM sys.tables
WHERE name IN
(
    'Customers',
    'Orders',
    'Products',
    'Employees',
    'Suppliers',
    'Categories'
);

go

CREATE DATABASE Northwind;
GO
USE Northwind;
GO

USE master;
GO

SELECT 
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
ORDER BY t.name;
go

USE master;
GO

SELECT
    OBJECT_SCHEMA_NAME(parent_object_id) AS TableSchema,
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName
FROM sys.foreign_keys
WHERE parent_object_id IN
(
    OBJECT_ID('dbo.Customers'),
    OBJECT_ID('dbo.Orders'),
    OBJECT_ID('dbo.Products'),
    OBJECT_ID('dbo.Employees'),
    OBJECT_ID('dbo.Suppliers'),
    OBJECT_ID('dbo.Categories')
);

go

USE master;
GO

SELECT 
    o.type_desc,
    SCHEMA_NAME(o.schema_id) AS SchemaName,
    o.name AS ObjectName
FROM sys.objects AS o
WHERE o.type IN ('V', 'P', 'FN', 'IF', 'TF')
ORDER BY o.type_desc, o.name;
go

USE master;
GO

SELECT 
    o.type_desc,
    SCHEMA_NAME(o.schema_id) AS SchemaName,
    o.name AS ObjectName
FROM sys.objects AS o
WHERE o.name IN
(
    'CustOrderHist',
    'CustOrdersDetail',
    'CustOrdersOrders',
    'Employee Sales by Country',
    'Sales by Year',
    'SalesByCategory',
    'Ten Most Expensive Products',

    'Alphabetical list of products',
    'Category Sales for 1997',
    'Current Product List',
    'Customer and Suppliers by City',
    'Invoices',
    'Order Details Extended',
    'Order Subtotals',
    'Orders Qry',
    'Product Sales for 1997',
    'Products Above Average Price',
    'Products by Category',
    'Quarterly Orders',
    'Sales by Category',
    'Sales Totals by Amount',
    'Summary of Sales by Quarter',
    'Summary of Sales by Year'
)
ORDER BY type_desc, ObjectName;
go


use Northwind
go


create table tl(
id int
)

go

drop table tl
go


USE master;
GO

ALTER DATABASE Northwind
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO


USE master;
GO

SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(s.database_id) AS DatabaseName,
    s.status
FROM sys.dm_exec_sessions AS s
WHERE s.database_id = DB_ID('Northwind');
go

KILL 59;
KILL 60;
GO

USE master;
GO

ALTER DATABASE Northwind
SET MULTI_USER;
GO

use toplearn
go

UPDATE personal
SET City = 'Tehran'
WHERE id = 1;
go

MERGE toplearn.dbo.personal AS T
USING toplearn_db.dbo.information AS S
ON T.ID = S.ID

WHEN MATCHED THEN
    UPDATE SET
        T.firstName = S.fName,
        T.City = S.City

WHEN NOT MATCHED BY TARGET THEN
    INSERT (firstName, City)
    VALUES (S.fName, S.City);

    go

    UPDATE personal
SET City = 'Tehran'
OUTPUT deleted.ID, deleted.City
WHERE ID = 2;
go

INSERT INTO personal (firstName, City)
OUTPUT inserted.ID, inserted.firstName, inserted.City
VALUES ('Ali', 'Tehran');
go

MERGE toplearn.dbo.personal AS T
USING toplearn_db.dbo.information AS S
ON T.ID = S.ID

WHEN MATCHED THEN
    UPDATE SET
        T.firstName = S.fName,
        T.City = S.City

WHEN NOT MATCHED BY TARGET THEN
    INSERT (firstName, City)
    VALUES (S.fName, S.City)

OUTPUT
    $action,
    inserted.ID,
    inserted.firstName,
    inserted.City;
    go
CREATE TABLE archive_personal
(
    ID INT,
    firstName NVARCHAR(100),
    City NVARCHAR(100)
);

go
DELETE FROM personal
OUTPUT
    DELETED.ID,
    DELETED.firstName,
    DELETED.City
INTO archive_personal
WHERE City = 'Tehran';
go

CREATE INDEX IX_personal_ID
ON personal(ID)
INCLUDE (firstName, City);

go

CREATE INDEX IX_personal_City_Name
ON personal(City, firstName);
go

SELECT *
FROM personal
WHERE City = 'karaj'
AND firstName = 'kamran';

go

SELECT *
FROM personal
WHERE firstName = 'kamran'
AND City = 'karaj';
go
CREATE FUNCTION dbo.CalculateTax
(
    @Amount DECIMAL(18, 2)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    RETURN @Amount * 0.09;
END;
go

SELECT dbo.CalculateTax(100000) AS TaxAmount;
go

SELECT GETDATE();
GO

SELECT GETDATE();
GO

CREATE FUNCTION dbo.CalculateTax
(
    @Amount DECIMAL(18, 2)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    RETURN @Amount * 0.09;
END;
GO
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name,
    type_desc,
    create_date,
    modify_date
FROM sys.objects
WHERE name = 'CalculateTax';

GO
use AdventureWorks2019
go
DROP FUNCTION IF EXISTS dbo.GetEmployeesBySalary;
GO


CREATE FUNCTION dbo.GetEmployeesBynationalidnumber
(
    @Minimumnationalidnumber DECIMAL(18, 2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM [HumanResources].[Employee] e
    WHERE e.nationalidnumber >= @Minimumnationalidnumber
);
go
CREATE VIEW dbo.vw_HighnationalidnumberEmployees
AS

SELECT *
FROM dbo.GetEmployeesBynationalidnumber(500000000);
go



USE MehrDataLab_Retail;

-- روش ۱: استاندارد
SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- روش ۲: مخصوص SQL Server
SELECT name, object_id, type_desc, create_date
FROM sys.tables;

SELECT *
FROM sys.tables;

SELECT *
FROM sys.schemas;

SELECT *
FROM sys.database_principals;

SELECT
    principal_id,
    name,
    type,
    type_desc,
    authentication_type_desc
FROM sys.database_principals;
go

SELECT *
FROM sys.system_objects;

go

SELECT
    name,
    object_id,
    parent_object_id,
    type_desc
FROM sys.tables;
go

SELECT
    name,
    object_id,
    principal_id,
    schema_id,
    parent_object_id,
    type,
    type_desc
FROM sys.objects
WHERE type = 'U';

go
---1---
SELECT
    name,
    object_id,
    parent_object_id,
    type_desc
FROM sys.tables;
go
----2----
SELECT
    fk.name,
    fkc.parent_object_id,
    fkc.referenced_object_id
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id;
go
---------3-----------

SELECT
    fk.name AS FK_Name,
    tp.name AS ReferencingTable,
    tr.name AS ReferencedTable
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp
    ON fkc.parent_object_id = tp.object_id
JOIN sys.tables tr
    ON fkc.referenced_object_id = tr.object_id;

go

use TSQLV4
go 
select cur.orderyear,cur.numcusts as curnumcusts,
      prv.numcusts as prvnumcusts,
       cur.numcusts-prv.numcusts as growth

from (select year(orderdate) as orderyear,
       count(distinct custid)as numcusts
       from sales.orders
group by year(orderdate)) as cur
left outer join 
(select year(orderdate) as orderyear,
       count(distinct custid)as numcusts
       from sales.orders
group by year(orderdate)) as prv
on cur.orderyear=prv.orderyear+1
go


with yearly as
(select top 100 percent year(orderdate) as orderyear,
       count(distinct custid)as numcusts
       from sales.orders
group by year(orderdate)
order by orderyear desc)
select cur.orderyear,cur.numcusts as curnumcusts,
      prv.numcusts as prvnumcusts,
       cur.numcusts-prv.numcusts as growth
from yearly as cur
left outer join yearly as prv
on cur.orderyear=prv.orderyear+1
go





with usacusts as
(select  custid , companyname
from sales.customers 
where country=N'usa')
select * from usacusts

go

