import pandas as pd
from sqlalchemy import create_engine

# --- اتصال به SQL Server ---
engine = create_engine(
    "mssql+pyodbc://@./MehrDataLab_Retail"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)

# --- لیست جداول برای خروجی گرفتن ---
tables = ["Fact_Sales", "Dim_Customers", "Dim_Products", "Dim_Geography"]

output_path = "MehrDataLab_Cleaned.xlsx"

# --- خواندن هر جدول و نوشتن در یک شیت جدا از همان فایل اکسل ---
with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
    for table in tables:
        df = pd.read_sql("SELECT * FROM dbo.vw_FactSales_Enriched", engine)
        df.to_excel(writer, sheet_name=table, index=False)
        print(f"✅ {table}: {len(df)} ردیف نوشته شد.")

print(f"🎉 فایل نهایی در '{output_path}' ذخیره شد.")