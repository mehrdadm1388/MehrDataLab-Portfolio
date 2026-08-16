import pandas as pd
from sqlalchemy import create_engine

# ===================================================
# ۱. توضیحات کسب‌وکاری — اینجا فارسی نوشتن هیچ مشکلی ندارد
#    کلید: (نام جدول, نام ستون)  →  مقدار: توضیح فارسی
# ===================================================
business_definitions = {
    ("Fact_Sales", "OrderID"):       "شناسه یکتای هر سفارش (Primary Key)",
    ("Fact_Sales", "OrderDate"):     "تاریخ ثبت سفارش",
    ("Fact_Sales", "CustomerID"):    "شناسه مشتری (Foreign Key به Dim_Customers)",
    ("Fact_Sales", "ProductID"):     "شناسه محصول (Foreign Key به Dim_Products)",
    ("Fact_Sales", "GeoID"):         "شناسه جغرافیایی (Foreign Key به Dim_Geography)",
    ("Fact_Sales", "Quantity"):      "تعداد واحد فروخته‌شده در سفارش",
    ("Fact_Sales", "UnitPrice"):     "قیمت واحد کالا پیش از اعمال تخفیف",
    ("Fact_Sales", "Sales"):         "فروش خالص پس از اعمال تخفیف (Quantity × UnitPrice × (1-Discount))",
    ("Fact_Sales", "Profit"):        "سود خالص سفارش",
    ("Fact_Sales", "PaymentMethod"): "روش پرداخت (نقدی، کارت، آنلاین)",
    ("Fact_Sales", "SalesPerson"):   "نام فروشنده مسئول سفارش",

    ("Dim_Customers", "CustomerID"):   "شناسه یکتای مشتری (Primary Key)",
    ("Dim_Customers", "CustomerName"): "نام مشتری (ممکن است برای یک CustomerID چند نام ثبت شده باشد)",
    ("Dim_Customers", "Gender"):       "جنسیت مشتری",
    ("Dim_Customers", "Age"):          "سن مشتری",
    ("Dim_Customers", "GeoID"):        "شناسه جغرافیایی محل سکونت مشتری",

    ("Dim_Products", "ProductID"): "شناسه یکتای محصول (Primary Key)",
    ("Dim_Products", "Product"):   "نام محصول",
    ("Dim_Products", "Category"):  "دسته‌بندی کالا",

    ("Dim_Geography", "GeoID"):    "شناسه یکتای موقعیت جغرافیایی (Primary Key)",
    ("Dim_Geography", "City"):     "نام شهر",
    ("Dim_Geography", "Province"): "نام استان",
}

# ===================================================
# ۲. اتصال به SQL Server و خواندن ساختار جداول
# ===================================================
engine = create_engine(
    "mssql+pyodbc://@./MehrDataLab_Retail"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)

metadata_query = """
SELECT
    OBJECT_NAME(c.object_id) AS TableName,
    c.name                   AS ColumnName,
    t.name                   AS DataType,
    c.max_length              AS MaxLength,
    c.is_nullable             AS IsNullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE OBJECT_NAME(c.object_id) IN ('Fact_Sales','Dim_Customers','Dim_Products','Dim_Geography')
ORDER BY TableName, c.column_id;
"""

df = pd.read_sql(metadata_query, engine)

# ===================================================
# ۳. اضافه کردن توضیح فارسی با merge (بر اساس جدول+ستون)
# ===================================================
df["BusinessDefinition"] = df.apply(
    lambda row: business_definitions.get((row["TableName"], row["ColumnName"]), "—"),
    axis=1
)

# ===================================================
# ۴. اکسپورت به Excel
# ===================================================
output_path = "Data_Dictionary.xlsx"
df.to_excel(output_path, index=False, sheet_name="Data_Dictionary")

print(f"✅ Data Dictionary با {len(df)} ستون در '{output_path}' ذخیره شد.")