import pandas as pd
import os
from abc import ABC, abstractmethod
from sqlalchemy import create_engine

# --- بخش اول: مدیریت خطاها ---
class DataError(Exception):
    pass

# --- بخش دوم: لایه بارگذاری (Extraction) ---
class DataSource(ABC):
    @abstractmethod
    def load(self):
        pass

class CSVSource(DataSource):
    def __init__(self, file_path):
        self.file_path = file_path

    def load(self):
        try:
            return pd.read_csv(self.file_path)
        except FileNotFoundError:
            raise DataError("CSV file not found")

class SQLSource(DataSource):
    def __init__(self, server, database, table):
        self.server = server
        self.database = database
        self.table = table

    def load(self):
        try:
            # استفاده از درایور استاندارد
            driver = "ODBC Driver 17 for SQL Server" 
            conn_str = f"mssql+pyodbc://{self.server}/{self.database}?driver={driver}&trusted_connection=yes"
            engine = create_engine(conn_str)
            query = f"SELECT * FROM {self.table}"
            return pd.read_sql(query, engine)
        except Exception as e:
            raise DataError(f"SQL Connection Error: {e}")

# --- بخش سوم: لایه پاکسازی (Transformation) ---
class DataCleaner(ABC):
    @abstractmethod
    def clean(self, data):
        pass

class DataFrameCleaner(DataCleaner):
    """این کلاس برای پاکسازی دیتافریم‌های پانداز طراحی شده"""
    def clean(self, df):
        if isinstance(df, pd.DataFrame):
            # مثال: حذف فضاهای خالی از نام ستون‌ها و تبدیل تمام متون به حروف کوچک
            df.columns = [col.strip().lower() for col in df.columns]
            # حذف ردیف‌های کاملاً خالی
            df = df.dropna(how='all')
            return df
        return df

# --- بخش چهارم: خط لوله اصلی (The Pipeline) ---
class Pipeline:
    def __init__(self, sources, cleaner: DataCleaner):
        self.sources = sources
        self.cleaner = cleaner  # حالا هر پایپ‌لاین یک پاک‌کننده مخصوص دارد

    def run(self):
        final_results = []

        for source in self.sources:
            try:
                print(f"--- Processing {type(source).__name__} ---")
                # مرحله 1: بارگذاری (Extract)
                raw_data = source.load()
                
                # مرحله 2: پاکسازی (Transform)
                cleaned_data = self.cleaner.clean(raw_data)
                
                final_results.append(cleaned_data)
                print(f"Successfully loaded and cleaned {type(source).__name__}")

            except DataError as e:
                print(f"Error in {type(source).__name__}: {e}")
            except Exception as e:
                print(f"Unexpected error in {type(source).__name__}: {e}")

        return final_results

# --- بخش پنجم: اجرای عملیات ---
if __name__ == "__main__":
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    FILENAME = os.path.join(BASE_DIR, "marriage_divorce_eda.csv")
    
    # تنظیمات SQL
    sql_config = {
        "server": ".",
        "database": "MehrDataLab",
        "table": "Students"
    }

    # ۱. تعریف منابع داده
    sources = [
        CSVSource(FILENAME),
        SQLSource(sql_config["server"], sql_config["database"], sql_config["table"])
    ]

    # ۲. تعریف استراتژی پاکسازی
    my_cleaner = DataFrameCleaner()

    # ۳. ساخت و اجرای پایپ‌لاین (ترکیب Load و Clean)
    pipeline = Pipeline(sources, my_cleaner)
    
    all_data = pipeline.run()

    print("\n--- Final Results ---")
    for i, df in enumerate(all_data):
        print(f"\nDataset {i+1}:")
        print(df.head()) # نمایش ۵ ردیف اول هر دیتاست
