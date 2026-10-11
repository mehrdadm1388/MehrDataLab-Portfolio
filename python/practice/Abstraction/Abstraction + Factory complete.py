import sys
import pandas as pd
from abc import ABC, abstractmethod
import os
from sqlalchemy import create_engine

# تنظیم انکودینگ برای جلوگیری از خطای Unicode در کنسول
sys.stdout.reconfigure(encoding="utf-8")

class DataError(Exception):
    pass

class DataSource(ABC):
    @abstractmethod
    def load(self):
        pass

class CSVSource(DataSource):
    def __init__(self, file_path):
        self.file_path = file_path

    def load(self):
        try:
            # اضافه کردن encoding برای خواندن صحیح فایل‌های فارسی در پانداز
            df = pd.read_csv(self.file_path, encoding='utf-8')
            return df
        except FileNotFoundError:
            raise DataError(f"CSV file not found at: {self.file_path}")
        except Exception as e:
            raise DataError(f"Error loading CSV: {e}")

class SQLSource(DataSource):
    def __init__(self, server, database, table):
        self.server = server
        self.database = database
        self.table = table

    def load(self):
        try:
            driver = "ODBC Driver 17 for SQL Server"
            # استفاده از f-string برای ساخت Connection String
            conn_str = f"mssql+pyodbc://{self.server}/{self.database}?driver={driver}&trusted_connection=yes"
            
            engine = create_engine(conn_str)
            query = f"SELECT * FROM {self.table}"
            return pd.read_sql(query, engine)
        except Exception as e:
            raise DataError(f"SQL Connection Error: {e}")

class APISource(DataSource):
    def load(self):
        return "API Data Loaded (Mock)"

def create_source(row):
    source_type = row["type"]

    if source_type == "csv":
        # اینجا مسیر فایل را از دیکشنری row می‌گیرد
        return CSVSource(file_path=row["path"])

    elif source_type == "sql":
        # اینجا پارامترهای SQL را از دیکشنری row می‌گیرد
        return SQLSource(
            server=row["config"]["server"],
            database=row["config"]["database"],
            table=row["config"]["table"]
        )

    elif source_type == "api":
        return APISource()

    else:
        raise ValueError(f"Unknown source: {source_type}")

# --- تنظیمات مورد نظر شما ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_FILENAME = os.path.join(BASE_DIR, "marriage_divorce_eda.csv")

sql_config = {
    "server": ".",
    "database": "MehrDataLab",
    "table": "Students"
}

# ساخت لیست منابع (Rows) با اطلاعات کامل
rows = [
    {"type": "csv", "path": CSV_FILENAME},
    {"type": "sql", "config": sql_config},
    {"type": "api"}
]

# اجرای فرآیند ETL/Load
sources = [create_source(row) for row in rows]

for source in sources:
    try:
        print(f"\n--- Loading Source: {type(source).__name__} ---")
        data = source.load()
        print(data)
    except DataError as e:
        print(f"Data Error: {e}")
    except Exception as e:
        print(f"Unexpected Error: {e}")
