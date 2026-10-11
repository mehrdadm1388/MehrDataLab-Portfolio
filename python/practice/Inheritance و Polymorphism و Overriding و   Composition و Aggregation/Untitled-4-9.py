import pandas as pd
import io

# ۱. تعریف خطای اختصاصی
class DataError(Exception):
    pass

# ۲. کلاس پایه (Interface)
class DataSource:
    def load(self):
        raise NotImplementedError

# --- کلاس‌های فرزند (پیاده‌سازی واقعی) ---

# منبع اول: داده‌های مستقیم از یک لیست (شبیه‌سازی API یا حافظه)
class ListDataSource(DataSource):
    def __init__(self, data_list):
        self.data_list = data_list

    def load(self):
        print("Loading data from List...")
        return pd.DataFrame(self.data_list)

# منبع دوم: خواندن از یک رشته شبیه فایل CSV (شبیه‌سازی فایل)
class CSVDataSource(DataSource):
    def __init__(self, csv_content):
        self.csv_content = csv_content

    def load(self):
        print("Loading data from CSV...")
        try:
          
            df = pd.read_csv(io.StringIO(self.csv_content))
            return df
        except Exception as e:
           
            raise DataError(f"CSV Load Failed: {e}")

class BrokenDataSource(DataSource):
    def load(self):
        print("Attempting to load from Broken Source...")
        raise DataError("Connection Timeout: Database is offline!")

# ۳. کلاس اصلی Pipeline
class Pipeline:
    def __init__(self, sources):
        self.sources = sources

    def run(self):
        results = []
        for source in self.sources:
            try:
                data = source.load()
                results.append(data)
            except DataError as e:
                print(f"!!! Pipeline Alert: {e}")
        return results

# --- اجرای نهایی برنامه ---

if __name__ == "__main__":
    # داده‌های نمونه برای منبع اول
    list_data = [
        {"name": "Mehdi", "role": "Data Analyst"},
        {"name": "Ali", "role": "Data Engineer"}
    ]

    # داده‌های نمونه برای منبع دوم (CSV)
    csv_data = """name,age,city
Sara,25,Tehran
Reza,30,Isfahan"""

    # ایجاد لیست منابع
    my_sources = [
        ListDataSource(list_data),      # منبع سالم ۱
        CSVDataSource(csv_data),         # منبع سالم ۲
        BrokenDataSource()               # منبع خراب
    ]

    # اجرای پایپ‌لاین
    print("--- Starting Data Pipeline ---\n")
    pipeline = Pipeline(my_sources)
    all_dataframes = pipeline.run()
    print("\n--- Pipeline Finished ---")

    # نمایش نتایج نهایی
    print("\nFinal Collected DataFrames:")
    for i, df in enumerate(all_dataframes):
        print(f"\nDataFrame {i+1}:")
        print(df)
