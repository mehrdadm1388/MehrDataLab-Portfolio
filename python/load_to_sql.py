import pandas as pd
from sqlalchemy import create_engine

# --- تنظیمات اتصال ---
# نکته: با ODBC Driver 18، به‌صورت پیش‌فرض Encrypt فعال است.
# روی سرور محلی/dev، TrustServerCertificate=yes لازم است تا خطای گواهی SSL ندهد.
engine = create_engine(
    "mssql+pyodbc://@./MehrDataLab_Retail"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
)

# --- تست اتصال ---
with engine.connect() as conn:
    print("✅ اتصال به SQL Server موفق بود.")

# --- بارگذاری شیت‌ها ---
excel_path = r"C:\Users\Mehdi\OneDrive\Desktop\projects\MehrDataLab-Portfolio\python\project1\outputs\clean_data.xlsx"

sheets = {
    "Fact_Sales": "Fact_Sales",
    "Dim_Customers": "Dim_Customers",
    "Dim_Products": "Dim_Products",
    "Dim_Geography": "Dim_Geography",
}

for sheet_name, table_name in sheets.items():
    df = pd.read_excel(excel_path, sheet_name=sheet_name)
    df.to_sql(table_name, engine, if_exists="replace", index=False, schema="dbo")
    print(f"✅ {table_name}: {len(df)} ردیف بارگذاری شد.")

print("🎉 بارگذاری تمام جداول به پایان رسید.")