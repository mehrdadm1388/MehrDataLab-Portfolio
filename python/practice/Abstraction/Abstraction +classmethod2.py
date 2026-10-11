import pandas as pd
import os

from abc import ABC, abstractmethod
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# ============================================================
# 1. مدیریت خطاها
# ============================================================


class DataError(Exception):
    """
    خطای عمومی مربوط به عملیات داده.
    """
    pass

# ============================================================
# 2. Abstraction + classmethod
# ============================================================


class DataSource(ABC):
    """
    کلاس انتزاعی برای تمام منابع داده.

    هر DataSource باید:
        1. بتواند خودش را از یک configuration بسازد
        2. متد load() را پیاده‌سازی کند
    """

    @classmethod
    @abstractmethod
    def from_dict(cls, config):
        """
        ساخت Object از روی configuration.

        cls یعنی کلاسی که متد را فراخوانی کرده است.
        """
        pass

    @abstractmethod
    def load(self):
        """
        استخراج داده از منبع.
        """
        pass

# ============================================================
# 3. CSV Source
# ============================================================


class CSVSource(DataSource):

    def __init__(self, file_path):
        self.file_path = file_path

    @classmethod
    def from_dict(cls, config):
        """
        ساخت CSVSource از dictionary.

        مثال config:

        {
            "type": "csv",
            "file_path": "sales.csv"
        }
        """

        return cls(
            config["file_path"]
        )

    def load(self):

        try:

            print(f"Loading CSV: {self.file_path}")

            df = pd.read_csv(self.file_path)

            if df.empty:
                raise DataError(
                    "CSV file is empty"
                )

            return df

        except FileNotFoundError:

            raise DataError(
                f"CSV file not found: {self.file_path}"
            )

        except pd.errors.EmptyDataError:

            raise DataError(
                "CSV file contains no data"
            )

# ============================================================
# 4. SQL Source
# ============================================================


class SQLSource(DataSource):

    def __init__(self, server, database, table):
        self.server = server
        self.database = database
        self.table = table

    @classmethod
    def from_dict(cls, config):
        """
        ساخت SQLSource از configuration.

        مثال:

        {
            "type": "sql",
            "server": ".",
            "database": "MehrDataLab",
            "table": "Students"
        }
        """

        return cls(
            config["server"],
            config["database"],
            config["table"]
        )

    def load(self):

        try:

            print(
                f"Loading SQL table: "
                f"{self.database}.{self.table}"
            )

            driver = "ODBC Driver 17 for SQL Server"

            connection_string = (
                f"DRIVER={{{driver}}};"
                f"SERVER={self.server};"
                f"DATABASE={self.database};"
                "Trusted_Connection=yes;"
            )

            connection_url = (
                "mssql+pyodbc:///?odbc_connect="
                +quote_plus(connection_string)
            )

            engine = create_engine(
                connection_url
            )

            query = f"""
                SELECT *
                FROM {self.table}
            """

            df = pd.read_sql(
                query,
                engine
            )

            if df.empty:
                raise DataError(
                    f"SQL table '{self.table}' is empty"
                )

            return df

        except DataError:
            raise

        except Exception as e:

            raise DataError(
                f"SQL Connection Error: {e}"
            )

# ============================================================
# 5. Abstraction برای Data Cleaning
# ============================================================


class DataCleaner(ABC):

    @abstractmethod
    def clean(self, data):
        pass

# ============================================================
# 6. DataFrame Cleaner
# ============================================================


class DataFrameCleaner(DataCleaner):
    """
    پاکسازی عمومی DataFrame.

    عملیات:

    1. پاکسازی نام ستون‌ها
    2. حذف ردیف‌های کاملاً خالی
    3. حذف فاصله‌های اضافی
    4. تبدیل رشته‌های خالی به NaN
    5. حذف duplicate
    6. نمایش missing values
    7. تلاش برای تبدیل ستون‌های عددی
    8. بررسی DataFrame نهایی
    """

    def clean(self, df):

        if not isinstance(df, pd.DataFrame):

            raise DataError(
                "Input must be a pandas DataFrame"
            )

        print("\n--- Cleaning Data ---")

        # ----------------------------------------------------
        # مرحله 1: کپی گرفتن
        # ----------------------------------------------------

        df = df.copy()

        print(
            f"Initial shape: {df.shape}"
        )

        # ----------------------------------------------------
        # مرحله 2: پاکسازی نام ستون‌ها
        # ----------------------------------------------------

        df.columns = (
            df.columns
            .str.strip()
            .str.lower()
            .str.replace(" ", "_")
        )

        print(
            "Column names cleaned."
        )

        # ----------------------------------------------------
        # مرحله 3: حذف ردیف‌های کاملاً خالی
        # ----------------------------------------------------

        before = len(df)

        df = df.dropna(
            how="all"
        )

        after = len(df)

        print(
            f"Empty rows removed: "
            f"{before - after}"
        )

        # ----------------------------------------------------
        # مرحله 4: تبدیل رشته خالی به NaN
        # ----------------------------------------------------

        df = df.replace(
            r"^\s*$",
            pd.NA,
            regex=True
        )

        print(
            "Blank strings converted to NaN."
        )

        # ----------------------------------------------------
        # مرحله 5: حذف فاصله اضافی در داده‌های متنی
        # ----------------------------------------------------

        text_columns = df.select_dtypes(
            include="object"
        ).columns

        for column in text_columns:

            df[column] = (
                df[column]
                .astype("string")
                .str.strip()
            )

        print(
            "Whitespace cleaned from text columns."
        )

        # ----------------------------------------------------
        # مرحله 6: حذف رکوردهای تکراری
        # ----------------------------------------------------

        before = len(df)

        df = df.drop_duplicates()

        after = len(df)

        print(
            f"Duplicate rows removed: "
            f"{before - after}"
        )

        # ----------------------------------------------------
        # مرحله 7: تلاش برای تبدیل ستون‌های عددی
        # ----------------------------------------------------

        for column in df.columns:

            if df[column].dtype == "object":

                converted = pd.to_numeric(
                    df[column],
                    errors="ignore"
                )

                df[column] = converted

        print(
            "Numeric columns checked."
        )

        # ----------------------------------------------------
        # مرحله 8: گزارش Missing Values
        # ----------------------------------------------------

        missing = df.isna().sum()

        missing = missing[
            missing > 0
        ]

        if not missing.empty:

            print(
                "\nMissing values:"
            )

            print(missing)

        else:

            print(
                "No missing values found."
            )

        # ----------------------------------------------------
        # مرحله 9: گزارش نهایی
        # ----------------------------------------------------

        print(
            f"\nFinal shape: {df.shape}"
        )

        return df

# ============================================================
# 7. Pipeline
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

            try:

                print(
                    "\n================================"
                )

                print(
                    f"Processing: "
                    f"{type(source).__name__}"
                )

                # --------------------------------------------
                # Extract
                # --------------------------------------------

                raw_data = source.load()

                print(
                    f"Raw shape: "
                    f"{raw_data.shape}"
                )

                # --------------------------------------------
                # Transform
                # --------------------------------------------

                cleaned_data = (
                    self.cleaner.clean(
                        raw_data
                    )
                )

                # --------------------------------------------
                # Save result
                # --------------------------------------------

                final_results.append(
                    cleaned_data
                )

                print(
                    "\nProcessing completed successfully."
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
# 8. اجرای برنامه
# ============================================================


if __name__ == "__main__":

    # --------------------------------------------------------
    # CSV configuration
    # --------------------------------------------------------

    BASE_DIR = os.path.dirname(
        os.path.abspath(__file__)
    )

    csv_config = {

        "type": "csv",

        "file_path": os.path.join(
            BASE_DIR,
            "marriage_divorce_eda.csv"
        )
    }

    # --------------------------------------------------------
    # SQL configuration
    # --------------------------------------------------------

    sql_config = {

        "type": "sql",

        "server": ".",

        "database": "MehrDataLab",

        "table": "Students"
    }

    # --------------------------------------------------------
    # ساخت DataSource ها
    #
    # اینجا classmethod وارد عمل می‌شود.
    # --------------------------------------------------------

    sources = [

        CSVSource.from_dict(
            csv_config
        ),

        SQLSource.from_dict(
            sql_config
        )
    ]

    # --------------------------------------------------------
    # ساخت Cleaner
    # --------------------------------------------------------

    cleaner = DataFrameCleaner()

    # --------------------------------------------------------
    # ساخت Pipeline
    # --------------------------------------------------------

    pipeline = Pipeline(
        sources,
        cleaner
    )

    # --------------------------------------------------------
    # اجرای Pipeline
    # --------------------------------------------------------

    all_data = pipeline.run()

    # --------------------------------------------------------
    # نمایش نتایج
    # --------------------------------------------------------

    print(
        "\n\n========== FINAL RESULTS =========="
    )

    for i, df in enumerate(
        all_data,
        start=1
    ):

        print(
            f"\nDataset {i}"
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
