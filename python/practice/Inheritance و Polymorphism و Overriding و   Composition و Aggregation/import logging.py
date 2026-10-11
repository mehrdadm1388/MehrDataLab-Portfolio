import logging

# تنظیمات Logging برای نمایش خطاهای پردازش داده
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

# --- 1. Custom Exceptions ---
class DataValidationError(Exception):
    """خطای اختصاصی برای داده‌های نامعتبر اقتصادی"""
    pass

# --- 2. Base Class (OOP) ---
class EconomicData:
    def __init__(self, country, year, value):
        self.country = country
        self.year = year
        self.value = value

    def calculate(self):
        return self.value

    def to_dict(self):
        """تبدیل شیء به دیکشنری برای خروجی نهایی"""
        return {
            "type": self.__class__.__name__,
            "country": self.country,
            "year": self.year,
            "original_value": self.value,
            "calculated_value": self.calculate()
        }

    def __repr__(self):
        return f"<{self.__class__.__name__} {self.country} {self.year}>"

# --- 3. Subclasses (Inheritance & Polymorphism) ---
class GDPData(EconomicData):
    def calculate(self):
        # GDP معمولاً همان مقدار اصلی است
        return self.value

class InflationData(EconomicData):
    def calculate(self):
        # تورم به صورت درصد است، برای محاسبات ممکن است نیاز به تبدیل داشته باشد
        return self.value / 100

class UnemploymentData(EconomicData):
    def calculate(self):
        # نرخ بیکاری
        return self.value / 100

# --- 4. Data Processing Engine (The Logic) ---
def process_economic_pipeline(raw_data_list):
    processed_results = []
    errors = []

    for entry in raw_data_list:
        try:
            # استخراج نوع داده از دیکشنری
            data_type = entry.get("type")
            country = entry.get("country")
            year = entry.get("year")
            value = entry.get("value")

            # بررسی وجود تمام فیلدهای ضروری (Data Validation)
            if None in (data_type, country, year, value):
                raise DataValidationError(f"Missing fields in entry: {entry}")

            # تبدیل مقدار به عدد (Data Cleaning)
            value = float(value)

            # انتخاب کلاس مناسب بر اساس نوع داده (Factory Logic)
            if data_type == "GDP":
                obj = GDPData(country, year, value)
            elif data_type == "Inflation":
                obj = InflationData(country, year, value)
            elif data_type == "Unemployment":
                obj = UnemploymentData(country, year, value)
            else:
                raise DataValidationError(f"Unknown data type: {data_type}")

            # اضافه کردن به لیست نتایج موفق
            processed_results.append(obj.to_dict())

        except (ValueError, TypeError, DataValidationError) as e:
            # ثبت خطا و ذخیره ردیف خراب برای گزارش‌دهی
            error_msg = f"Error processing {entry}: {e}"
            logging.error(error_msg)
            errors.append({"entry": entry, "error": str(e)})
            continue # رفتن به ردیف بعدی (اصل Resilience)

    return processed_results, errors

# --- 5. Raw Data (With Errors and Mixed Types) ---
raw_data = [
    {"type": "GDP", "country": "Iran", "year": 2023, "value": "400"},        # سالم
    {"type": "Inflation", "country": "Iran", "year": 2023, "value": "45"},  # سالم
    {"type": "Unemployment", "country": "Iran", "year": 2023, "value": "10"},# سالم
    {"type": "GDP", "country": "Germany", "year": 2023, "value": "not_a_number"}, # خطای مقدار (ValueError)
    {"type": "Inflation", "country": "USA", "year": 2024, "value": "3.5"},   # سالم
    {"type": "Unknown", "country": "Japan", "year": 2024, "value": "100"},   # خطای نوع نامعتبر (DataValidationError)
    {"type": "GDP", "country": "China", "year": 2023},                       # خطای فیلد ناقص (Missing Fields)
    {"type": "Unemployment", "country": "Brazil", "year": 2022, "value": "8"}, # سالم
]

# --- 6. Execution & Output ---
if __name__ == "__main__":
    print("🚀 Starting Data Pipeline...\n")
    
    successes, failures = process_economic_pipeline(raw_data)

    print("\n✅ SUCCESSFUL RECORDS:")
    print("-" * 30)
    for item in successes:
        print(item)

    print("\n❌ FAILED RECORDS (Error Log):")
    print("-" * 30)
    for err in failures:
        print(f"Data: {err['entry']} | Reason: {err['error']}")

    print(f"\n📊 Summary: {len(successes)} processed, {len(failures)} failed.")
