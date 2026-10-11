import os
import pandas as pd

from abc import ABC, abstractmethod
from sqlalchemy import create_engine
from urllib.parse import quote_plus


# ============================================================
# 1) مدیریت خطاها
# ============================================================
#
# به جای اینکه خطاهای مختلف را مستقیماً در Pipeline مدیریت کنیم،
# یک Exception پایه برای خطاهای مربوط به داده تعریف می‌کنیم.
#
# ساختار:
#
# DataError
#    ├── ExtractionError
#    ├── CleaningError
#    └── LoadingError
#
# این کار باعث می‌شود Pipeline بتواند خطاهای مرتبط با داده را
# با یک except مدیریت کند.
# ============================================================

class DataError(Exception):
    pass


class ExtractionError(DataError):
    pass


class CleaningError(DataError):
    pass


class LoadingError(DataError):
    pass


# ============================================================
# 2) لایه Extraction
# ============================================================
#
# Abstraction:
#
# Pipeline نباید بداند داده از CSV آمده یا SQL یا API.
#
# فقط می‌داند هر DataSource باید متد load() داشته باشد.
#
# بنابراین:
#
# CSVSource       -> load()
# SQLSource       -> load()
# APISource       -> load()
#
# همه یک Interface مشترک دارند.
# ============================================================

class DataSource(ABC):

    @abstractmethod
    def load(self):
        """
        هر منبع داده باید متد load داشته باشد.
        """
        pass


# ============================================================
# 3) CSV Source
# ============================================================

class CSVSource(DataSource):

    def __init__(self, file_path):
        self.file_path = file_path

    def load(self):

        try:

            # بررسی می‌کنیم فایل واقعاً وجود دارد
            if not os.path.exists(self.file_path):
                raise ExtractionError(
                    f"File not found: {self.file_path}"
                )

            # خواندن CSV
            df = pd.read_csv(self.file_path)

            # اگر DataFrame خالی باشد
            if df.empty:
                raise ExtractionError(
                    "CSV file contains no data."
                )

            return df

        except ExtractionError:
            # خطایی که خودمان ایجاد کرده‌ایم
            # دوباره DataError تولید نمی‌کنیم.
            raise

        except pd.errors.EmptyDataError:
            raise ExtractionError(
                "CSV file is empty."
            )

        except pd.errors.ParserError as e:
            raise ExtractionError(
                f"CSV parsing error: {e}"
            )

        except Exception as e:
            raise ExtractionError(
                f"Unexpected CSV error: {e}"
            )


# ============================================================
# 4) SQL Source
# ============================================================

class SQLSource(DataSource):

    def __init__(self, server, database, table):
        self.server = server
        self.database = database
        self.table = table

    def load(self):

        try:

            driver = "ODBC Driver 17 for SQL Server"

            connection_string = (
                f"DRIVER={{{driver}}};"
                f"SERVER={self.server};"
                f"DATABASE={self.database};"
                "Trusted_Connection=yes;"
            )

            connection_url = (
                "mssql+pyodbc:///?odbc_connect="
                + quote_plus(connection_string)
            )

            engine = create_engine(connection_url)

            query = f"SELECT * FROM {self.table}"

            df = pd.read_sql(query, engine)

            if df.empty:
                raise ExtractionError(
                    f"SQL table '{self.table}' contains no data."
                )

            return df

        except DataError:
            raise

        except Exception as e:
            raise ExtractionError(
                f"SQL extraction error: {e}"
            )


# ============================================================
# 5) لایه Transformation / Cleaning
# ============================================================
#
# دوباره Abstraction استفاده می‌کنیم.
#
# هر Cleaner باید متد clean() داشته باشد.
#
# DataFrameCleaner
#      ↓
# clean()
#
# بعداً می‌توانیم Cleanerهای دیگری داشته باشیم:
#
# SalesCleaner
# CustomerCleaner
# EconomicDataCleaner
# etc.
# ============================================================

class DataCleaner(ABC):

    @abstractmethod
    def clean(self, data):
        """
        هر Cleaner باید داده را دریافت و
        نسخه پاکسازی‌شده را برگرداند.
        """
        pass


class DataFrameCleaner(DataCleaner):

    def clean(self, df):

        try:

            # ------------------------------------------------
            # مرحله 1: بررسی نوع داده
            # ------------------------------------------------
            #
            # Cleaner ما مخصوص pandas DataFrame است.
            #
            if not isinstance(df, pd.DataFrame):
                raise CleaningError(
                    "Input must be a pandas DataFrame."
                )


            # ------------------------------------------------
            # مرحله 2: Copy
            # ------------------------------------------------
            #
            # بهتر است روی نسخه‌ای از DataFrame کار کنیم
            # تا DataFrame اصلی تغییر نکند.
            #
            df = df.copy()


            # ------------------------------------------------
            # مرحله 3: حذف فاصله از نام ستون‌ها
            # ------------------------------------------------
            #
            # مثلاً:
            #
            # " Customer ID "
            #
            # تبدیل می‌شود به:
            #
            # "Customer ID"
            #
            df.columns = df.columns.str.strip()


            # ------------------------------------------------
            # مرحله 4: استانداردسازی نام ستون‌ها
            # ------------------------------------------------
            #
            # مثال:
            #
            # "Customer ID"
            #      ↓
            # "customer_id"
            #
            # این استانداردسازی برای Data Analysis و
            # Data Engineering بسیار مفید است.
            #
            df.columns = (
                df.columns
                .str.lower()
                .str.replace(" ", "_")
                .str.replace("-", "_")
            )


            # ------------------------------------------------
            # مرحله 5: حذف ستون‌های بدون نام
            # ------------------------------------------------
            #
            # گاهی CSV شامل ستون‌هایی مثل:
            #
            # Unnamed: 0
            #
            # است.
            #
            unnamed_columns = [
                col for col in df.columns
                if col.startswith("unnamed:")
            ]

            if unnamed_columns:
                df = df.drop(
                    columns=unnamed_columns
                )


            # ------------------------------------------------
            # مرحله 6: حذف ردیف‌هایی که کاملاً خالی هستند
            # ------------------------------------------------

            df = df.dropna(
                how="all"
            )


            # ------------------------------------------------
            # مرحله 7: حذف ستون‌هایی که کاملاً خالی هستند
            # ------------------------------------------------

            df = df.dropna(
                axis=1,
                how="all"
            )


            # ------------------------------------------------
            # مرحله 8: حذف فاصله از داده‌های متنی
            # ------------------------------------------------
            #
            # مثلاً:
            #
            # " Tehran "
            #
            # تبدیل می‌شود به:
            #
            # "Tehran"
            #
            # فقط ستون‌های متنی را تغییر می‌دهیم.
            # ------------------------------------------------

            text_columns = df.select_dtypes(
                include="object"
            ).columns

            for col in text_columns:

                df[col] = (
                    df[col]
                    .astype("string")
                    .str.strip()
                )


            # ------------------------------------------------
            # مرحله 9: تبدیل رشته‌های خالی به NaN
            # ------------------------------------------------
            #
            # این موارد:
            #
            # ""
            # " "
            # "N/A"
            # "NA"
            # "null"
            #
            # ممکن است در داده به معنی Missing Value باشند.
            #
            # ------------------------------------------------

            df = df.replace(
                [
                    "",
                    " ",
                    "N/A",
                    "NA",
                    "NULL",
                    "null"
                ],
                pd.NA
            )


            # ------------------------------------------------
            # مرحله 10: حذف رکوردهای تکراری
            # ------------------------------------------------
            #
            # Duplicate Record یکی از مشکلات رایج داده است.
            #
            before = len(df)

            df = df.drop_duplicates()

            after = len(df)

            print(
                f"Duplicate rows removed: {before - after}"
            )


            # ------------------------------------------------
            # مرحله 11: تبدیل ستون‌های عددی
            # ------------------------------------------------
            #
            # اگر pandas ستونی را object تشخیص داده باشد
            # ولی مقادیر آن در واقع عددی باشند، تلاش می‌کنیم
            # آن را به numeric تبدیل کنیم.
            #
            # errors='ignore' یعنی اگر تبدیل ممکن نبود،
            # مقدار را دستکاری نکن.
            # ------------------------------------------------

            for col in df.columns:

                if df[col].dtype == "object":

                    converted = pd.to_numeric(
                        df[col],
                        errors="coerce"
                    )

                    # اگر حداقل 80 درصد مقادیر قابل تبدیل
                    # به عدد باشند، ستون را numeric می‌کنیم.

                    valid_ratio = converted.notna().mean()

                    if valid_ratio >= 0.80:
                        df[col] = converted


            # ------------------------------------------------
            # مرحله 12: گزارش Missing Values
            # ------------------------------------------------
            #
            # فعلاً Missing Value را حذف نمی‌کنیم.
            #
            # چون حذف Missing همیشه تصمیم درستی نیست.
            #
            # ممکن است:
            #
            # - حذف کنیم
            # - با میانگین پر کنیم
            # - با median پر کنیم
            # - با mode پر کنیم
            # - forward fill انجام دهیم
            # - یا Missing را به عنوان یک وضعیت نگه داریم.
            #
            # این تصمیم به Business Problem بستگی دارد.
            # ------------------------------------------------

            missing = df.isna().sum()

            missing = missing[
                missing > 0
            ]

            if not missing.empty:

                print("\nMissing Values:")

                print(missing)


            # ------------------------------------------------
            # مرحله 13: بررسی تعداد رکوردها
            # ------------------------------------------------

            if df.empty:

                raise CleaningError(
                    "DataFrame became empty after cleaning."
                )


            # ------------------------------------------------
            # مرحله 14: بازگرداندن داده پاک‌شده
            # ------------------------------------------------

            return df


        except CleaningError:
            raise

        except Exception as e:

            raise CleaningError(
                f"Unexpected cleaning error: {e}"
            )


# ============================================================
# 6) Pipeline
# ============================================================
#
# اینجا مهم‌ترین بخش OOP را می‌بینیم.
#
# Pipeline به نوع واقعی Source کاری ندارد.
#
# فقط می‌گوید:
#
# source.load()
#
# و:
#
# cleaner.clean()
#
# این یعنی:
#
# Abstraction
# +
# Polymorphism
# +
# Aggregation
#
# Pipeline اشیای Source و Cleaner را از بیرون دریافت می‌کند.
# ============================================================

class Pipeline:

    def __init__(
        self,
        sources,
        cleaner: DataCleaner
    ):

        self.sources = sources
        self.cleaner = cleaner


    def run(self):

        final_results = []


        for source in self.sources:

            print(
                "\n================================"
            )

            print(
                f"Processing: {type(source).__name__}"
            )

            print(
                "================================"
            )


            try:

                # --------------------------------------------
                # مرحله 1: Extract
                # --------------------------------------------

                print("1. Extracting...")

                raw_data = source.load()


                print(
                    f"Rows extracted: {len(raw_data)}"
                )

                print(
                    f"Columns extracted: {len(raw_data.columns)}"
                )


                # --------------------------------------------
                # مرحله 2: Transform / Clean
                # --------------------------------------------

                print("\n2. Cleaning...")

                cleaned_data = self.cleaner.clean(
                    raw_data
                )


                # --------------------------------------------
                # مرحله 3: ذخیره نتیجه
                # --------------------------------------------

                final_results.append(
                    cleaned_data
                )


                print("\nCleaning completed.")

                print(
                    f"Rows after cleaning: "
                    f"{len(cleaned_data)}"
                )

                print(
                    f"Columns after cleaning: "
                    f"{len(cleaned_data.columns)}"
                )


            except DataError as e:

                print(
                    f"\nData Error in "
                    f"{type(source).__name__}: {e}"
                )


            except Exception as e:

                print(
                    f"\nUnexpected error in "
                    f"{type(source).__name__}: {e}"
                )


        return final_results


# ============================================================
# 7) اجرای برنامه
# ============================================================

if __name__ == "__main__":

    # --------------------------------------------------------
    # مسیر فایل CSV
    # --------------------------------------------------------

    BASE_DIR = os.path.dirname(
        os.path.abspath(__file__)
    )

    FILENAME = os.path.join(
        BASE_DIR,
        "marriage_divorce_eda.csv"
    )


    # --------------------------------------------------------
    # تنظیمات SQL Server
    # --------------------------------------------------------

    sql_config = {

        "server": ".",

        "database": "MehrDataLab",

        "table": "Students"
    }


    # --------------------------------------------------------
    # ساخت Data Sources
    #
    # Aggregation:
    #
    # Pipeline این objectها را خودش نمی‌سازد.
    # از بیرون دریافت می‌کند.
    # --------------------------------------------------------

    sources = [

        CSVSource(
            FILENAME
        ),

        SQLSource(
            sql_config["server"],
            sql_config["database"],
            sql_config["table"]
        )
    ]


    # --------------------------------------------------------
    # ساخت Cleaner
    # --------------------------------------------------------

    my_cleaner = DataFrameCleaner()


    # --------------------------------------------------------
    # ساخت Pipeline
    # --------------------------------------------------------

    pipeline = Pipeline(
        sources,
        my_cleaner
    )


    # --------------------------------------------------------
    # اجرای ETL
    # --------------------------------------------------------

    all_data = pipeline.run()


    # ========================================================
    # نمایش نتایج
    # ========================================================

    print("\n\n================================")
    print("FINAL RESULTS")
    print("================================")


    for i, df in enumerate(all_data):

        print(
            f"\nDataset {i + 1}"
        )

        print(
            "------------------------------"
        )

        print(
            f"Shape: {df.shape}"
        )

        print(
            "\nColumns:"
        )

        print(
            df.columns.tolist()
        )

        print(
            "\nFirst 5 rows:"
        )

        print(
            df.head()
        )

        print(
            "\nData Types:"
        )

        print(
            df.dtypes
        )

        print(
            "\nMissing Values:"
        )

        print(
            df.isna().sum()
        )