# مستندسازی کوئری‌های تمرینی T-SQL (Practice_.sql)

> این فایل، توضیح تخصصی هر بلوک کوئری از فایل `Practice_.sql` است. ترتیب دقیقاً مطابق فایل اصلی حفظ شده تا هم برای مرور شخصی و هم برای مستندسازی در GitHub قابل استفاده باشد.

---

## بخش ۱ | DDL/DML پایه روی دیتابیس `toplearn`

```sql
use toplearn

create table Dbo.information(
ID  int   not null,
Fname nvarchar(30)  not null,
lname nvarchar(30)  not null,
country nvarchar(100)  null,
)
```
**توضیح:** ساخت جدول پایه با یک ستون nullable (`country`) و بقیه NOT NULL. نکتهٔ حرفه‌ای: نبود Primary Key روی `ID` یک ضعف طراحی است؛ بدون PK یکتایی سطرها تضمین نمی‌شود.

```sql
insert into [dbo].[information](...) values (2,'mehdi','M','Iran'),(3,'farhad','h','Iran')
```
**توضیح:** درج چند-ردیفی (multi-row VALUES) — روش استاندارد و کارآمدتر نسبت به چند دستور INSERT جداگانه.

```sql
delete from [dbo].[information] where ID=3
delete from [dbo].[information] where Fname='mehdi'
```
**توضیح:** دو DELETE مجزا با شرط‌های متفاوت؛ نمونهٔ حذف نقطه‌ای (targeted delete). نکته: چون PK وجود ندارد، فیلتر روی `Fname` می‌تواند بیش از یک سطر را حذف کند — ریسک داده‌ای.

```sql
drop table [dbo].[information]
```
**توضیح:** حذف کامل جدول (ساختار + داده). برگشت‌ناپذیر است مگر در تراکنش.

```sql
use toplearn_db
truncate table [dbo].[Information]
```
**توضیح:** تعویض دیتابیس و سپس TRUNCATE — سریع‌تر از DELETE چون IDENTITY را ریست می‌کند و لاگ تراکنشی کمتری تولید می‌کند، اما شرط WHERE نمی‌پذیرد و اگر FK داشته باشد اجرا نمی‌شود.

```sql
insert into [dbo].[Information](ID,fname,lname,city) values
(1,'mehrdad','m','tehran'),(2,'kamran','f','arak'),(3,'sara','m','tehran')
```
**توضیح:** پر کردن مجدد جدول بعد از TRUNCATE با ستون `city` به‌جای `country` (تفاوت اسکیمای این جدول با نسخهٔ قبلی در `toplearn`).

```sql
select city ,* from [dbo].[Information]
```
**توضیح:** الگوی رایج ولی **ناکارآمد**: تکرار `city` هم به‌صورت صریح هم داخل `*` باعث دوبار دیدن همان ستون در خروجی می‌شود. در کد پرتفوی توصیه می‌شود ستون‌ها صریح لیست شوند، نه `SELECT *`.

```sql
select top(2) Fname,city from [dbo].[Information]
```
**توضیح:** `TOP` بدون `ORDER BY` — نتیجه غیرقطعی (non-deterministic) است؛ SQL Server تضمین نمی‌کند کدام ۲ سطر برگردد. برای پرتفوی حتماً باید `ORDER BY` اضافه شود.

```sql
update [dbo].[Information] set city='karaj', lname='farahani' where id=2
```
**توضیح:** UPDATE چند-ستونی استاندارد با شرط تک‌سطری.

---

## بخش ۲ | مدیریت فایل‌گروه‌ها (Filegroups)

```sql
alter database [toplearn] add filegroup fg1
select * from sys.filegroups
alter database [toplearn] add file(name='personal', filename='C:\filegroupssms\personal.ndf') to filegroup fg1
```
**توضیح:** ساخت یک Filegroup ثانویه و افزودن فایل داده (`.ndf`) به آن. این تکنیک در سناریوهای واقعی برای جداسازی فیزیکی جداول حجیم/آرشیوی از فایل اصلی (`PRIMARY`) و بهبود I/O یا استراتژی بکاپ استفاده می‌شود — موضوعی که مستقیماً به فاز Data Warehousing/Storage Design مرتبط است.

---

## بخش ۳ | کاوش اولیه در `MehrDataLab` / نمونهٔ JOIN

```sql
use [MehrDataLab]
select * from [dbo].[Students]

SELECT c.CustomerName, o.OrderDate
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;
```
**توضیح:** بلوک اول کاوش ساده روی جدول `Students` است. بلوک دوم یک INNER JOIN استاندارد نمونه (احتمالاً از یک تمرین آموزشی جداگانه، چون جداول `Customers`/`Orders` در این اسکیما تعریف نشده‌اند در همین فایل).

```sql
USE MehrDataLab_Retail;
SELECT @@SERVERNAME;
SELECT SERVERPROPERTY('InstanceName') AS InstanceName;
```
**توضیح:** دو روش برای گرفتن اطلاعات سرور فعلی — `@@SERVERNAME` نام کامل سرور را برمی‌گرداند، `SERVERPROPERTY('InstanceName')` فقط نام Instance را (برای named instance ها کاربردی است؛ برای default instance مقدار NULL می‌دهد).

---

## بخش ۴ | Collation، ستون‌ها، Default، Sparse Column

```sql
alter table [dbo].[personal]
alter column [FirstName] nvarchar(50) collate Albanian_BIN
```
**توضیح:** تغییر Collation یک ستون به‌صورت مستقل از دیتابیس. `Albanian_BIN` یک collation باینری است (case-sensitive و accent-sensitive) — احتمالاً برای تمرین مفهوم Collation انتخاب شده، نه انتخابی که در دادهٔ فارسی/بین‌المللی توصیه شود (برای متن فارسی معمولاً `Persian_100_CI_AS` یا `Arabic_CI_AS` مناسب‌تر است).

```sql
select * from ::fn_helpcollations()
```
**توضیح:** تابع سیستمی که تمام Collation های موجود روی SQL Server را لیست می‌کند — ابزار کاوشی برای انتخاب Collation درست.

```sql
alter table [dbo].[personal] add city nvarchar(50) null
alter table [dbo].[personal] add constraint df_city default 'TEHRAN' for city
```
**توضیح:** افزودن ستون جدید و سپس یک DEFAULT CONSTRAINT نام‌گذاری‌شده (best practice نسبت به default بی‌نام) روی همان ستون.

```sql
alter table [dbo].[personal] alter column [Mobail] int sparse null
```
**توضیح:** تبدیل ستون به `SPARSE` — بهینه‌سازی فضای ذخیره‌سازی برای ستون‌هایی که اکثر مقادیرشان NULL است (کاهش هزینهٔ ذخیره‌سازی به قیمت افزایش سربار خواندن/نوشتن مقادیر غیر-NULL).

---

## بخش ۵ | View ها: ساده، با لیست ستون، SCHEMABINDING، ENCRYPTION، CHECK OPTION

```sql
create view Vw_personal as
select [id],[FirstName],[city] from [dbo].[personal]
```
**توضیح:** View ساده بدون هیچ محدودیت خاص.

```sql
create or alter view [dbo].[Vw_personal]([FirstName],[Mobail],[city]) as
select [FirstName],[Mobail],[city] from [dbo].[personal]
```
**توضیح:** همان View با نام‌گذاری صریح ستون‌ها در تعریف (column-list syntax) — مفید وقتی می‌خواهید نام ستون خروجی View با نام ستون مبدأ متفاوت باشد یا خوانایی تعریف را بالا ببرید.

```sql
CREATE OR ALTER VIEW dbo.Vw_personal2
WITH SCHEMABINDING
AS
SELECT id, FirstName FROM dbo.personal;
```
**توضیح:** View با SCHEMABINDING — جدول پایه را قفل می‌کند تا تغییر ساختاری (مثل DROP یا ALTER ستون‌های استفاده‌شده) امکان‌پذیر نباشد. پیش‌نیاز ساخت Indexed View. مطابق حافظهٔ پروژهٔ MehrDataLab، این دقیقاً همان الگویی است که در `vw_SalesByCity` استفاده شده.

```sql
create or alter view dbo.Vw_personal3
with encryption
as
select * from dbo.personal where id>=2
with check option
```
**توضیح:** دو ویژگی هم‌زمان: `WITH ENCRYPTION` متن تعریف View را در `sys.syscomments`/metadata رمزنگاری می‌کند (غیرقابل مشاهده با `sp_helptext`)، و `WITH CHECK OPTION` تضمین می‌کند هر INSERT/UPDATE از طریق این View باید شرط `WHERE id>=2` را رعایت کند وگرنه رد می‌شود.

---

## بخش ۶ | Constraint ها روی `personal`

```sql
select * from personal p order by p.FirstName desc

alter table personal add check (len(firstname) >=3 and len(firstname)<=20)

alter table personal drop constraint if exists [CK__personal__FirstN__72C60C4A]
```
**توضیح:** یک CHECK CONSTRAINT بی‌نام (SQL Server نام خودکار مثل `CK__personal__...` تولید می‌کند) برای اعتبارسنجی طول نام، سپس حذف آن با `IF EXISTS` (روش امن که خطا نمی‌دهد اگر Constraint وجود نداشته باشد). نکتهٔ حرفه‌ای: در محیط پروداکشن باید Constraint ها را همیشه با نام صریح (`CONSTRAINT CK_personal_FirstName_Length`) ساخت تا مدیریت و مستندسازی ساده‌تر شود.

---

## بخش ۷ | JOIN ها روی `TSQLV4` (الگوی قدیمی در برابر استاندارد)

```sql
select c.custid, c.companyname, o.orderid, od.qty, od.productid
from [Sales].[Customers] as c, [Sales].[OrderDetails] as od, [Sales].[Orders] as o
```
**توضیح:** سبک قدیمی JOIN با کاما (comma-join / implicit join) بدون شرط اتصال — این یک **CROSS JOIN ضمنی و پرخطر** است (نتیجه = ضرب دکارتی، مگر شرط در WHERE اضافه شود که اینجا نیامده). این الگو منسوخ (deprecated) است و در کد پرتفوی نباید استفاده شود.

```sql
select ... from Sales.Customers as c
inner join Sales.Orders as o on c.custid=o.custid
inner join Sales.OrderDetails as od on od.orderid=o.orderid and od.productid=11;
```
**توضیح:** نسخهٔ درست و استاندارد (ANSI-92 JOIN). شرط `od.productid=11` داخل `ON` قرار گرفته که یعنی فیلتر **قبل از** JOIN اعمال می‌شود — روی INNER JOIN از نظر منطقی با گذاشتنش در WHERE یکسان است، ولی روی LEFT JOIN رفتار کاملاً متفاوتی دارد (تفاوت مهمی که باید در مصاحبه توضیح داده شود).

```sql
-- همان کوئری با فرمت خوانا و بدون alias کوتاه در برخی خطوط
```
**توضیح:** بازنویسی همان JOIN با قالب‌بندی رسمی‌تر (indent و newline استاندارد) — تمرین سبک‌نویسی کد خوانا برای مستندسازی.

```sql
-- همان JOIN اما فیلتر productid=11 در WHERE به‌جای ON
```
**توضیح:** نسخهٔ سوم که فیلتر را به WHERE منتقل می‌کند. روی این INNER JOIN خاص نتیجه با نسخهٔ قبلی یکسان است؛ تمرین خوبی برای درک تفاوت جای‌گذاری شرط فیلتر در ON در مقابل WHERE.

```sql
select * from [Sales].[Orders]
select * from [Sales].[Customers]
select * from [Sales].[OrderDetails]
```
**توضیح:** کاوش اکتشافی ساختار سه جدول اصلی قبل از نوشتن JOIN — روش درست کار یک تحلیلگر: همیشه قبل از JOIN زدن، دادهٔ خام هر جدول را ببینید.

---

## بخش ۸ | IDENTITY_INSERT

```sql
use toplearn
set identity_insert personal on
insert personal ([id],[c_id],[FirstName],[LastName],[Mobail],[city])
   values(4,1,'akbar','t',1357,'tabriz')
set identity_insert personal off

insert personal ([c_id],[FirstName],[LastName],[Mobail],[city])
   values(1,'abas','f',1357,'arak')
```
**توضیح:** `personal.id` یک ستون IDENTITY است. بلوک اول با روشن‌کردن `IDENTITY_INSERT` مقدار `id=4` را دستی وارد می‌کند (برای بازیابی داده یا هم‌ترازی بین محیط‌ها کاربرد دارد؛ فقط یک جدول در هر زمان می‌تواند این حالت را روشن داشته باشد). بلوک دوم درج معمولی است که `id` را خودِ SQL Server تولید می‌کند.

---

## بخش ۹ | CTE، Paging، فیلترهای متنی، CASE

```sql
with toplern_cte as (
select * from [Production].[Categories] cross join [HR].[Employees]
)
select * from toplern_cte
```
**توضیح:** یک CTE که خودش شامل CROSS JOIN صریح است (عمدی، برخلاف comma-join بخش ۷). نتیجه = تعداد دسته × تعداد کارمند — برای تولید تمام ترکیب‌های ممکن (مثلاً سناریوی تخصیص).

```sql
select * from [HR].[Employees] e
order by e.hiredate
offset 3 rows fetch next 5 rows only
```
**توضیح:** الگوی Pagination استاندارد T-SQL (از SQL Server 2012 به بعد) — رد کردن ۳ سطر اول و برداشتن ۵ سطر بعدی، بر اساس ترتیب `hiredate`. جایگزین مدرن‌تر `TOP` برای صفحه‌بندی نتایج در گزارش‌ها یا API هاست.

```sql
where e.empid between 3 and 6
where e.firstname like '%s%'
where e.firstname like '__s%'
where e.firstname like 'p%a'
```
**توضیح:** چهار الگوی فیلتر: `BETWEEN` برای بازهٔ عددی (inclusive هر دو طرف)، و سه حالت `LIKE`:
- `%s%` → هر جایی حرف s وجود داشته باشد
- `__s%` → دقیقاً دو کاراکتر اول هرچه باشد، سومین کاراکتر s باشد
- `p%a` → شروع با p و پایان با a

```sql
CASE
    WHEN e.birthdate <= '1970-01-01' THEN 'aged'
    WHEN e.birthdate > '1970-01-01' AND e.birthdate <= '1990-01-01' THEN 'Middle-aged'
    WHEN e.birthdate > '1990-01-01' THEN 'Young'
    ELSE 'error in birthdate'
END AS AgeGroup
```
**توضیح:** Simple business-rule bucketing با CASE Expression — دقیقاً همان الگویی که در پروژهٔ MehrDataLab برای دسته‌بندی مشتریان/محصولات به‌کار می‌رود. نکته: چون ورودی همیشه یک تاریخ معتبر یا NULL است، شاخهٔ `ELSE` عملاً فقط حالت NULL را پوشش می‌دهد (نه «خطا» به معنای واقعی).

---

## بخش ۱۰ | Columnstore Index

```sql
use toplearn_db
create nonclustered columnstore index csi on [dbo].[Information](fname,lname)
```
**توضیح:** ساخت یک Nonclustered Columnstore Index روی دو ستون رشته‌ای. این نوع ایندکس برای کوئری‌های تحلیلی/Aggregate روی حجم بالای داده بهینه است (فشرده‌سازی ستونی + Batch Execution Mode)، نه برای OLTP سطر-به-سطر. روی جدولی به این کوچکی صرفاً جنبهٔ آموزشی دارد.

---

## بخش ۱۱ | Anti-Join با NOT IN بین دو دیتابیس

```sql
use toplearn
select * from [dbo].[personal] p
where p.id not in (select id from [toplearn_db].[dbo].Information)
```
**توضیح:** کوئری Cross-Database با نام سه‌بخشی (`database.schema.table`). **هشدار مهم:** اگر زیرکوئری حتی یک مقدار `NULL` در ستون `id` برگرداند، کل شرط `NOT IN` هیچ سطری برنمی‌گرداند (رفتار سه‌ارزشی NULL در SQL) — این یکی از رایج‌ترین باگ‌های تولید-محور در T-SQL است، دقیقاً همان چیزی که در کامنت فارسی خود فایل هم اشاره شده.

---

## بخش ۱۲ | Schema ها

```sql
create schema sls
alter schema sls transfer country
alter schema dbo transfer sls.country
```
**توضیح:** ساخت Schema جدید (`sls`) به‌عنوان ابزار سازمان‌دهی منطقی اشیاء دیتابیس (نه فیزیکی)، انتقال جدول `country` از `dbo` به `sls`، و سپس بازگرداندنش به `dbo`. در معماری Enterprise، Schema ها معمولاً برای جداسازی دسترسی/مسئولیت بین تیم‌ها (مثل `sales`, `hr`, `staging`) استفاده می‌شوند.

---

## بخش ۱۳ | EXISTS / ANY / ALL

```sql
select * from [dbo].[country] c
where exists (select * from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')
```
**توضیح:** Correlated Subquery با `EXISTS` — روش بهینه و امن (بر خلاف `NOT IN`) برای بررسی وجود رکورد مرتبط، چون NULL باعث رفتار غیرمنتظره نمی‌شود. توجه: `LIKE 'M%'` (حرف بزرگ) در ادامه با `LIKE 'm%'` (حرف کوچک) تکرار شده — بسته به Collation دیتابیس (اگر Case-Insensitive باشد، مثل اکثر پیش‌فرض‌های فارسی/انگلیسی) نتیجه یکسان خواهد بود.

```sql
where c.ID = any (select p.id from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')
where c.ID = all (select p.id from [dbo].[personal] p where c.ID=p.id and p.FirstName LIKE 'M%')
```
**توضیح:** `= ANY` معادل منطقی `IN` است (اگر با حداقل یکی از مقادیر زیرکوئری برابر باشد، true). `= ALL` بسیار محدودکننده‌تر است: فقط وقتی true می‌شود که `c.ID` با **تمام** مقادیر بازگشتی برابر باشد — عملاً یا زیرکوئری تک-مقداره باشد یا هیچ سطری برنگردد (که آنگاه ALL همیشه true است، رفتاری ضدشهودی که باید در مصاحبه توضیح داده شود).

---

## بخش ۱۴ | امنیت: User بدون Login و Impersonation

```sql
create user atoosa without login
alter role [db_datareader] add member atoosa
execute as user = 'atoosa'
revert
```
**توضیح:** ساخت یک Database User که به هیچ Login سروری متصل نیست (برای اجرای کد تحت هویت محدود، الگوی رایج در Stored Procedure های امن)، افزودن آن به نقش `db_datareader` (دسترسی فقط-خواندنی کل دیتابیس)، سپس `EXECUTE AS` برای شبیه‌سازی موقت هویت آن کاربر و `REVERT` برای بازگشت به هویت اصلی.

---

## بخش ۱۵ | Sequence Object

```sql
create sequence mehrseq increment by 3 minvalue 10 maxvalue 3000 cycle

create table tet_seq(id int primary key not null, lfamily nvarchar(20) not null)

alter table tet_seq add default next value for mehrseq for id

insert into tet_seq(lfamily) values (N'mo'),(N'fa')
```
**توضیح:** `SEQUENCE` یک شیء تولید عدد مستقل از جدول است (بر خلاف IDENTITY که به یک ستون خاص متصل است). با گام ۳، بازهٔ ۱۰ تا ۳۰۰۰ و `CYCLE` (وقتی به سقف رسید از اول شروع می‌کند). سپس با `DEFAULT NEXT VALUE FOR` به ستون `id` وصل شده — یعنی این کد PK را بدون IDENTITY، از طریق Sequence مقداردهی می‌کند. استفاده از `N'...'` برای رشته‌ها هم رعایت درست Unicode-safety است.

---

## بخش ۱۶ | زیرکوئری اسکالر (Scalar Subquery)

```sql
use AdventureWorks2019
declare @maxid as int = (select max(SalesOrderID) from [Sales].[SalesOrderDetail])
select ShipDate, SalesOrderNumber, ShipToAddressID from [Sales].[SalesOrderHeader] s
where s.SalesOrderID=@maxid
```
**توضیح:** ذخیرهٔ نتیجهٔ یک Scalar Subquery در متغیر، سپس استفاده در کوئری اصلی. ⚠️ **نکتهٔ حرفه‌ای مهم:** `MAX(SalesOrderID)` از جدول `SalesOrderDetail` گرفته شده، نه از `SalesOrderHeader`. چون هر Order می‌تواند چند سطر Detail داشته باشد، `SalesOrderID` در Detail لزوماً به‌ترتیب یکتای Header نیست و این می‌تواند نتیجهٔ گمراه‌کننده بدهد (باید مقدار max از خودِ Header گرفته شود). این دقیقاً نوع باگ ظریفی است که ارزش مستندسازی به‌عنوان «یافتهٔ کیفیت داده» دارد.

```sql
select ShipDate, SalesOrderNumber, ShipToAddressID from [Sales].[SalesOrderHeader] s
where s.SalesOrderID=(select max(SalesOrderID) from [Sales].[SalesOrderDetail])
```
**توضیح:** همان منطق بدون متغیر میانی — Inline Scalar Subquery. از نظر Performance تفاوت معناداری با نسخهٔ قبلی ندارد (Optimizer معمولاً یکسان اجرا می‌کند)، فقط سبک نوشتاری فرق دارد.

---

## بخش ۱۷ | هشدار NOT IN + عملگرهای Set

```sql
use TSQLV4
select orderid from sales.orders o
where empid in (select e.empid from [HR].[Employees] e where lastname like N'D%')
```
**توضیح:** الگوی درست IN (نه NOT IN) — امن است چون مشکل NULL فقط در NOT IN رخ می‌دهد. کامنت فارسی بالای این کوئری («اینجا بنویسی مساوی مستعد تولید باگه») و کامنت زیرش («جاهایی که NOT IN دارید یا به LEFT JOIN تبدیل کنید یا از NOT EXISTS استفاده کنید») یک یادداشت شخصی و کاملاً درست دربارهٔ best practice است — پیشنهاد می‌کنم این نکته عیناً در بخش «Lessons Learned» مستندات پروژه ثبت شود.

```sql
select city from hr.Employees union select city from sales.Customers
select city from hr.Employees union all select city from sales.Customers
select city from hr.Employees intersect select city from sales.Customers
select city from hr.Employees except select city from sales.Customers
```
**توضیح:** چهار عملگر Set روی دو ستون هم‌نوع:
- `UNION` → ترکیب و حذف تکراری‌ها
- `UNION ALL` → ترکیب بدون حذف تکراری (سریع‌تر، بدون Sort/Distinct داخلی)
- `INTERSECT` → فقط شهرهایی که در هر دو لیست مشترک‌اند
- `EXCEPT` → شهرهایی که در Employees هست ولی در Customers نیست (ترتیب سمت چپ/راست مهم است)

---

## بخش ۱۸ | کاوش متادیتا در سطح Instance (`master`, `sys.*`)

```sql
SELECT DB_NAME() AS CurrentDatabase;
SELECT name FROM sys.databases;
USE master; SELECT name FROM sys.databases ORDER BY name;
```
**توضیح:** بررسی دیتابیس فعال و لیست تمام دیتابیس‌های موجود روی instance — قدم اول استاندارد قبل از هر کار Administrative.

```sql
SELECT name FROM sys.tables
WHERE name IN ('Customers','Orders','Products','Employees','Suppliers','Categories');
```
**توضیح:** بررسی اینکه آیا جداول کلاسیک Northwind در دیتابیس فعلی (`master`، که خودش دیتابیس سیستمی است و طبیعتاً این جداول را ندارد) وجود دارند یا نه — این کوئری در `master` همیشه خالی برمی‌گردد، تمرین برای فهم تفاوت Scope دیتابیس‌ها.

```sql
CREATE DATABASE Northwind;
USE Northwind;
```
**توضیح:** ساخت دیتابیس خالی جدید به نام `Northwind` (فقط شِل دیتابیس، بدون جدول — جداول کلاسیک Northwind باید جداگانه با اسکریپت رسمی نصب شوند).

```sql
SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables AS t INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
ORDER BY t.name;
```
**توضیح:** لیست تمام جداول به‌همراه Schema صاحب آن‌ها — روش استاندارد برای Discovery ساختار یک دیتابیس ناشناخته (دقیقاً کاری که برای مستندسازی خودکار Data Dictionary در MehrDataLab هم انجام شده).

```sql
SELECT OBJECT_SCHEMA_NAME(parent_object_id) ..., name AS ConstraintName
FROM sys.foreign_keys
WHERE parent_object_id IN (OBJECT_ID('dbo.Customers'), ...);
```
**توضیح:** بررسی Foreign Key های تعریف‌شده روی جداول کلاسیک Northwind — چون دیتابیس تازه‌ساخته خالی است، نتیجه خالی است؛ ساختار کوئری برای زمانی که جداول واقعی import شوند آماده است.

```sql
SELECT o.type_desc, SCHEMA_NAME(o.schema_id), o.name
FROM sys.objects AS o WHERE o.type IN ('V','P','FN','IF','TF')
ORDER BY o.type_desc, o.name;
```
**توضیح:** لیست تمام View ها (`V`)، Stored Procedure ها (`P`) و انواع Function ها (`FN`=Scalar, `IF`=Inline Table-Valued, `TF`=Multi-statement Table-Valued) — یک نقشهٔ کامل از اشیاء برنامه‌نویسی‌شدهٔ دیتابیس.

```sql
SELECT o.type_desc, SCHEMA_NAME(o.schema_id), o.name
FROM sys.objects AS o
WHERE o.name IN ('CustOrderHist','CustOrdersDetail', ... 'Summary of Sales by Year')
```
**توضیح:** جست‌وجوی مستقیم برای نام‌های دقیق View/Procedure های معروف نسخهٔ رسمی Northwind (شامل نام‌هایی با فاصله مثل `'Employee Sales by Country'` که نشان می‌دهد این پایگاه‌داده اصلاً از Access به SQL Server منتقل شده بود).

---

## بخش ۱۹ | چرخهٔ حیات دیتابیس Northwind: ساخت، قفل تک‌کاربره، Kill Session

```sql
use Northwind
create table tl(id int)
drop table tl
```
**توضیح:** تست سریع ساخت/حذف جدول برای تأیید دسترسی نوشتن روی دیتابیس تازه‌ساز.

```sql
USE master;
ALTER DATABASE Northwind SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
```
**توضیح:** قفل کردن دیتابیس در حالت تک‌کاربره و **Rollback فوری هر تراکنش باز دیگری** — معمولاً قبل از عملیات حساس مثل Restore، Rename، یا Drop استفاده می‌شود تا هیچ Session دیگری مزاحم نباشد.

```sql
SELECT s.session_id, s.login_name, s.host_name, s.program_name,
       DB_NAME(s.database_id) AS DatabaseName, s.status
FROM sys.dm_exec_sessions AS s
WHERE s.database_id = DB_ID('Northwind');
```
**توضیح:** DMV (Dynamic Management View) برای مشاهدهٔ Session های فعال روی دیتابیس Northwind — ابزار تشخیصی استاندارد DBA/DE برای فهمیدن چه کسی/چه برنامه‌ای در حال استفاده از دیتابیس است.

```sql
KILL 59;
KILL 60;
```
**توضیح:** خاتمهٔ اجباری Session های شناسایی‌شده که مانع اعمال `SINGLE_USER` می‌شدند. ⚠️ باید با احتیاط زیاد و فقط بعد از بررسی دقیق `program_name`/`login_name` استفاده شود.

```sql
ALTER DATABASE Northwind SET MULTI_USER;
```
**توضیح:** بازگرداندن دیتابیس به حالت عادی چند-کاربره پس از پایان عملیات نگهداری.

---

## بخش ۲۰ | UPDATE/INSERT/MERGE با OUTPUT و Cross-Database MERGE

```sql
use toplearn
UPDATE personal SET City = 'Tehran' WHERE id = 1;
```
**توضیح:** UPDATE ساده.

```sql
MERGE toplearn.dbo.personal AS T
USING toplearn_db.dbo.information AS S
ON T.ID = S.ID
WHEN MATCHED THEN UPDATE SET T.firstName = S.fName, T.City = S.City
WHEN NOT MATCHED BY TARGET THEN INSERT (firstName, City) VALUES (S.fName, S.City);
```
**توضیح:** MERGE بین دو دیتابیس مختلف (`toplearn` و `toplearn_db`) — عملیات Upsert کلاسیک: اگر ID مشترک بود UPDATE، اگر نبود INSERT. این دقیقاً همان الگوی SCD (Slowly Changing Dimension) نوع ۱ است که در فاز Data Warehousing/Kimball روی آن کار خواهید کرد — نکتهٔ خوبی برای پل زدن به مطالعهٔ *The Data Warehouse Toolkit*.

```sql
UPDATE personal SET City = 'Tehran'
OUTPUT deleted.ID, deleted.City
WHERE ID = 2;
```
**توضیح:** استفاده از بند `OUTPUT` برای بازگرداندن مقادیر **قبل از تغییر** (`deleted.*`) در همان دستور UPDATE — بسیار مفید برای Audit Log بدون نیاز به Trigger جداگانه.

```sql
INSERT INTO personal (firstName, City)
OUTPUT inserted.ID, inserted.firstName, inserted.City
VALUES ('Ali', 'Tehran');
```
**توضیح:** همینطور `OUTPUT inserted.*` روی INSERT — بازگرداندن ID تولیدشده توسط IDENTITY بلافاصله بعد از درج، بدون نیاز به `SCOPE_IDENTITY()`.

```sql
MERGE ... WHEN MATCHED ... WHEN NOT MATCHED BY TARGET ...
OUTPUT $action, inserted.ID, inserted.firstName, inserted.City;
```
**توضیح:** همان MERGE قبلی، این بار با `OUTPUT $action` که مشخص می‌کند هر سطر خروجی نتیجهٔ `INSERT` بوده یا `UPDATE` — ابزار قدرتمند برای گزارش‌دهی دقیق نتیجهٔ عملیات ETL.

```sql
CREATE TABLE archive_personal (ID INT, firstName NVARCHAR(100), City NVARCHAR(100));

DELETE FROM personal
OUTPUT DELETED.ID, DELETED.firstName, DELETED.City INTO archive_personal
WHERE City = 'Tehran';
```
**توضیح:** الگوی حرفه‌ای **Archive-on-Delete**: با `OUTPUT ... INTO` سطرهای حذف‌شده مستقیماً و در همان تراکنش به جدول آرشیو منتقل می‌شوند — تضمین می‌کند هیچ داده‌ای بین DELETE و درج در آرشیو گم نشود (اتمیک است).

---

## بخش ۲۱ | ایندکس‌گذاری و اثر ترتیب ستون‌ها

```sql
CREATE INDEX IX_personal_ID ON personal(ID) INCLUDE (firstName, City);
CREATE INDEX IX_personal_City_Name ON personal(City, firstName);
```
**توضیح:** ایندکس اول یک Covering Index است: کلید `ID` + ستون‌های `INCLUDE` (که در برگ ایندکس ذخیره می‌شوند ولی جزو کلید مرتب‌سازی نیستند) — برای کوئری‌هایی که با `ID` فیلتر می‌کنند ولی `firstName`/`City` را هم می‌خواهند، بدون نیاز به Key Lookup. ایندکس دوم یک ایندکس ترکیبی (Composite) روی `(City, firstName)` است.

```sql
SELECT * FROM personal WHERE City = 'karaj' AND firstName = 'kamran';
SELECT * FROM personal WHERE firstName = 'kamran' AND City = 'karaj';
```
**توضیح:** دو کوئری با شرط یکسان ولی ترتیب متفاوت در WHERE. نکتهٔ کلیدی: **ترتیب نوشتن شرط‌ها در WHERE اهمیتی برای Optimizer ندارد** (Query Optimizer بازنویسی می‌کند)؛ آنچه واقعاً مهم است ترتیب ستون‌ها در تعریف ایندکس (`City, firstName`) است. این کوئری دقیقاً برای اثبات همین نکته در کنار ایندکس بالا نوشته شده — تمرین خوبی برای مصاحبهٔ Performance Tuning.

---

## بخش ۲۲ | Scalar Function

```sql
CREATE FUNCTION dbo.CalculateTax(@Amount DECIMAL(18,2))
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN @Amount * 0.09;
END;

SELECT dbo.CalculateTax(100000) AS TaxAmount;
```
**توضیح:** یک Scalar User-Defined Function ساده برای محاسبهٔ مالیات ۹٪. ⚠️ هشدار Performance: Scalar UDF های کلاسیک (پیش از SQL Server 2019 Scalar UDF Inlining) وقتی روی هر سطر یک نتیجهٔ بزرگ فراخوانی شوند، به‌شدت کند می‌شوند چون Row-by-Row اجرا می‌شوند نه Set-Based. برای پروژهٔ پرتفوی بهتر است این منطق را در Computed Column یا مستقیماً در عبارت SELECT بنویسید.

```sql
SELECT GETDATE();
```
**توضیح:** گرفتن تاریخ/زمان فعلی سرور (دو بار تکرار شده، احتمالاً برای مقایسهٔ سریع timestamp).

```sql
SELECT SCHEMA_NAME(schema_id), name, type_desc, create_date, modify_date
FROM sys.objects WHERE name = 'CalculateTax';
```
**توضیح:** بررسی متادیتای شیء تابع (تاریخ ساخت/آخرین تغییر) از `sys.objects` — روش استاندارد Auditing بدون نیاز به Third-party tool.

---

## بخش ۲۳ | Inline Table-Valued Function و View روی آن (AdventureWorks2019)

```sql
use AdventureWorks2019
DROP FUNCTION IF EXISTS dbo.GetEmployeesBySalary;

CREATE FUNCTION dbo.GetEmployeesBynationalidnumber(@Minimumnationalidnumber DECIMAL(18,2))
RETURNS TABLE
AS
RETURN (
    SELECT * FROM [HumanResources].[Employee] e
    WHERE e.nationalidnumber >= @Minimumnationalidnumber
);
```
**توضیح:** Inline Table-Valued Function (iTVF) — بر خلاف Scalar UDF، این نوع تابع توسط Optimizer مثل یک View پارامتری‌شده «Inline» می‌شود و Performance آن معمولاً بسیار بهتر از Scalar UDF یا Multi-statement TVF است. نکته: نام پارامتر و منطق (`nationalidnumber >= ...`) نشان می‌دهد این احتمالاً باید `GetEmployeesBySalary` باشد ولی به‌اشتباه براساس National ID Number فیلتر می‌کند — یک نمونهٔ خوب برای مستندسازی به‌عنوان «باگ نام‌گذاری/منطق کد» در گزارش کیفیت.

```sql
CREATE VIEW dbo.vw_HighnationalidnumberEmployees AS
SELECT * FROM dbo.GetEmployeesBynationalidnumber(500000000);
```
**توضیح:** ساخت View روی یک iTVF با پارامتر ثابت — الگوی رایج برای «قفل کردن» یک فیلتر پرکاربرد پشت یک نام قابل‌فهم برای کاربران گزارش‌گیری.

---

## بخش ۲۴ | کاوش متادیتای کامل `MehrDataLab_Retail`

```sql
USE MehrDataLab_Retail;
SELECT TABLE_NAME, TABLE_TYPE FROM INFORMATION_SCHEMA.TABLES;
SELECT name, object_id, type_desc, create_date FROM sys.tables;
```
**توضیح:** دو روش استاندارد و ANSI-portable (`INFORMATION_SCHEMA`) در برابر روش اختصاصی و کامل‌تر SQL Server (`sys.tables`) برای لیست جداول. `INFORMATION_SCHEMA` بین موتورهای مختلف SQL قابل انتقال است، `sys.*` اطلاعات داخلی بیشتری (مثل `object_id`) می‌دهد.

```sql
SELECT * FROM sys.tables;
SELECT * FROM sys.schemas;
SELECT * FROM sys.database_principals;
SELECT principal_id, name, type, type_desc, authentication_type_desc FROM sys.database_principals;
SELECT * FROM sys.system_objects;
```
**توضیح:** کاوش کامل سیستم Catalog: جداول، اسکیماها، Principal های امنیتی دیتابیس (کاربران/نقش‌ها) و اشیاء سیستمی داخلی SQL Server — این دقیقاً همان روشی است که موتور Data-Dictionary خودکار پایتونی پروژهٔ MehrDataLab (که از `sys.columns` می‌خواند) از آن الهام گرفته است.

```sql
SELECT name, object_id, principal_id, schema_id, parent_object_id, type, type_desc
FROM sys.objects WHERE type = 'U';
```
**توضیح:** فیلتر دقیق روی نوع `'U'` (User Table) — یعنی فقط جداول واقعی، بدون View/Procedure/System Object.

```sql
---1---
SELECT name, object_id, parent_object_id, type_desc FROM sys.tables;

---2---
SELECT fk.name, fkc.parent_object_id, fkc.referenced_object_id
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id;

---3---
SELECT fk.name AS FK_Name, tp.name AS ReferencingTable, tr.name AS ReferencedTable
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id;
```
**توضیح:** سه مرحلهٔ تدریجی برای استخراج نقشهٔ کامل روابط FK دیتابیس Star Schema: ابتدا لیست خام جداول، سپس اتصال خام `sys.foreign_keys` به `sys.foreign_key_columns` (که فقط ID های داخلی دارد)، و در نهایت JOIN دوباره با `sys.tables` برای تبدیل ID ها به نام‌های خوانای انسانی (`ReferencingTable` / `ReferencedTable`). این دقیقاً تکنیکی است که برای اعتبارسنجی خودکار ساختار Fact/Dimension در فاز SQL پروژهٔ MehrDataLab قابل استفاده است.

---

## بخش ۲۵ | تحلیل رشد سال‌به‌سال مشتریان (الگوی پیش از Window Functions)

```sql
use TSQLV4
select cur.orderyear, cur.numcusts as curnumcusts,
       prv.numcusts as prvnumcusts,
       cur.numcusts - prv.numcusts as growth
from (
    select year(orderdate) as orderyear, count(distinct custid) as numcusts
    from sales.orders group by year(orderdate)
) as cur
left outer join (
    select year(orderdate) as orderyear, count(distinct custid) as numcusts
    from sales.orders group by year(orderdate)
) as prv
on cur.orderyear = prv.orderyear + 1
```
**توضیح:** الگوی کلاسیک **Self-Join روی زیرکوئری تجمیعی** برای محاسبهٔ رشد سال‌به‌سال — دقیقاً همان مسئله‌ای که در پروژهٔ MehrDataLab با تابع پنجره‌ای `LAG()` حل شده است. این نسخه، راه‌حل «پیش از Window Functions» است: همان زیرکوئری دوبار (با نام مستعار `cur` و `prv`) اجرا و با شرط `orderyear = orderyear + 1` به هم متصل می‌شود. آموزنده است چون تفاوت کارایی و خوانایی را در برابر `LAG(numcusts) OVER (ORDER BY orderyear)` به‌وضوح نشان می‌دهد.

```sql
with yearly as (
    select top 100 percent year(orderdate) as orderyear, count(distinct custid) as numcusts
    from sales.orders group by year(orderdate)
    order by orderyear desc
)
select cur.orderyear, cur.numcusts as curnumcusts,
       prv.numcusts as prvnumcusts,
       cur.numcusts - prv.numcusts as growth
from yearly as cur
left outer join yearly as prv on cur.orderyear = prv.orderyear + 1
```
**توضیح:** بازنویسی همان منطق با CTE به‌جای دو زیرکوئری تکراری (DRY-تر) و Self-Join روی همان CTE. نکتهٔ فنی مهم: `TOP 100 PERCENT ... ORDER BY` داخل CTE یک ترفند قدیمی و **غیرقابل‌اتکا** است — SQL Server هیچ تضمینی نمی‌دهد که ترتیب CTE در کوئری بیرونی حفظ شود (ORDER BY فقط برای TOP معتبر است، نه برای کل CTE). این خودش یک نکتهٔ خوب برای مستندسازی «چرا نباید به این ترفند اعتماد کرد» است.

```sql
with usacusts as (
    select custid, companyname from sales.customers where country=N'usa'
)
select * from usacusts
```
**توضیح:** یک CTE سادهٔ فیلتری روی مشتریان آمریکایی — مثال پایه برای معرفی CTE، پایان‌بخش فایل تمرینی.

---

## جمع‌بندی برای مستندسازی پروژه

این فایل تمرینی، طیف کاملی از موضوعات T-SQL را پوشش می‌دهد: DDL/DML پایه، Views (شامل SCHEMABINDING/ENCRYPTION)، JOIN (از comma-join منسوخ تا ANSI-92)، Subquery ها (EXISTS/ANY/ALL/NOT IN و خطرات آن)، Set Operators، MERGE/OUTPUT، Indexing، Function ها (Scalar و Table-Valued)، Sequence، امنیت (User/Role/Impersonation)، و کاوش متادیتای سیستمی (`sys.*`). چند نکتهٔ کیفیت داده/کد قابل توجه برای مستندسازی در README یا گزارش پروژه:

1. **الگوی NOT IN با ریسک NULL** — هشدار داده‌شده در خود کامنت فارسی فایل، باید در بخش Lessons Learned پروژه ثبت شود.
2. **باگ احتمالی در محاسبهٔ `@maxid`** روی `AdventureWorks2019` (گرفتن MAX از جدول Detail به‌جای Header).
3. **TOP بدون ORDER BY** → نتیجهٔ غیرقطعی.
4. **TOP 100 PERCENT + ORDER BY داخل CTE** → ترفند غیرقابل‌اتکا برای حفظ ترتیب.
5. **نام‌گذاری گمراه‌کننده** در تابع `GetEmployeesBynationalidnumber` (به‌جای Salary).

اگر بخواهید، می‌توانم این فایل را به یک سند Word رسمی (`.docx`) با فرمت‌بندی حرفه‌ای (فهرست مطالب، سرصفحه) هم تبدیل کنم، یا نسخهٔ اصلاح‌شدهٔ (Refactored) این اسکریپت را بر اساس best practice ها (نام‌گذاری صریح Constraint ها، حذف comma-join، اضافه‌کردن ORDER BY به TOP و ...) آماده کنم.
