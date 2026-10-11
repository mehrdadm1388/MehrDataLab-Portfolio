import pandas as pd

# ۱. تعریف خطای اختصاصی برای مدیریت خطاهای مربوط به داده
class DataError(Exception):
    pass

# ۲. کلاس پایه (Interface)
class DataSource:
    def load(self):
        raise NotImplementedError

# ۳. پیاده‌سازی کلاس برای خواندن از فایل CSV واقعی
class CSVDataSource(DataSource):
    def __init__(self, file_path):
        self.file_path = file_path

    def load(self):
        print(f"Attempting to load data from: {self.file_path}")
        try:
            # خواندن فایل از روی هارد دیسک
            df = pd.read_csv(self.file_path)
            
            # یک چک ساده برای اطمینان از اینکه فایل خالی نیست
            if df.empty:
                raise DataError("The loaded CSV file is empty!")
                
            print("Successfully loaded data!")
            return df
        except FileNotFoundError:
            raise DataError(f"Error: The file '{self.file_path}' was not found.")
        except Exception as e:
            # هر خطای دیگری (مثل مشکل در فرمت فایل) را به DataError تبدیل می‌کنیم
            raise DataError(f"An unexpected error occurred: {e}")

# ۴. کلاس مدیریت جریان داده (Pipeline)
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
                # اگر خطایی از نوع DataError بود، برنامه متوقف نمی‌شود، فقط خطا را چاپ می‌کند
                print(f"!!! Pipeline Alert: {e}")
        return results

# --- بخش اصلی اجرای برنامه ---
if __name__ == "__main__":
    # نام فایل شما که در همان پوشه است
    FILENAME = "marriage_divorce_eda.csv"

    # ایجاد لیست منابع (در اینجا فقط یک منبع داریم: فایل شما)
    # من یک منبع فرضی دیگر هم اضافه می‌کنم که اگر فایل نبود، برنامه کرش نکند
    my_sources = [
        CSVDataSource(FILENAME)
    ]

    print("--- Starting Data Pipeline ---\n")
    
    pipeline = Pipeline(my_sources)
    all_dataframes = pipeline.run()

    print("\n--- Pipeline Finished ---")

    # نمایش نتایج
    if all_dataframes:
        print(f"\nTotal DataFrames loaded: {len(all_dataframes)}")
        for i, df in enumerate(all_dataframes):
            print(f"\nContent of DataFrame {i+1}:")
            print(df.head()) # فقط ۵ سطر اول را نشان می‌دهد تا خروجی شلوغ نشود
            print("\nSummary Statistics:")
            print(df.describe()) # اطلاعات آماری داده‌ها
    else:
        print("\nNo data was loaded. Check if the filename is correct.")
