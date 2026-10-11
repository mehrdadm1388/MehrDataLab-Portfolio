import os
import pandas as pd                 # third-party
from abc import ABC, abstractmethod # standard
from sqlalchemy import create_engine # third-party
from urllib.parse import quote_plus  # standard


# ============================================================
# 1. Custom Exceptions
# ============================================================

class ETLError(Exception):
    """Base exception for the ETL system."""
    pass


class ExtractionError(ETLError):
    pass


class TransformationError(ETLError):
    pass


class LoadingError(ETLError):
    pass


# ============================================================
# 2. Abstract DataSource
# ============================================================

class DataSource(ABC):

    @classmethod
    @abstractmethod
    def from_dict(cls, row):
        """
        Create an object from configuration.
        """
        pass

    @abstractmethod
    def load(self):
        """
        Extract data from the source.
        """
        pass


# ============================================================
# 3. CSV Source
# ============================================================

class CSVSource(DataSource):

    def __init__(self, file_path):
        self.file_path = file_path

    @classmethod
    def from_dict(cls, row):
        return cls(row["file_path"])

    def load(self):

        print(f"\nLoading CSV:")
        print(f"  {self.file_path}")

        try:
            df = pd.read_csv(self.file_path)

            if df.empty:
                raise ExtractionError(
                    f"CSV file is empty: {self.file_path}"
                )

            return df

        except FileNotFoundError:

            raise ExtractionError(
                f"File not found: {self.file_path}"
            )

        except pd.errors.EmptyDataError:

            raise ExtractionError(
                f"CSV file contains no data: {self.file_path}"
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
    def from_dict(cls, row):

        return cls(
            row["server"],
            row["database"],
            row["table"]
        )

    def load(self):

        print("\nLoading SQL:")
        print(
            f"  Server   : {self.server}\n"
            f"  Database : {self.database}\n"
            f"  Table    : {self.table}"
        )

        try:

            connection_string = (
                "DRIVER={ODBC Driver 17 for SQL Server};"
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
                    f"SQL table is empty: {self.table}"
                )

            return df

        except Exception as e:

            raise ExtractionError(
                f"SQL extraction failed: {e}"
            )


# ============================================================
# 5. Abstract Cleaner
# ============================================================

class DataCleaner(ABC):

    @abstractmethod
    def clean(self, data):
        pass


# ============================================================
# 6. Pandas Data Cleaner
# ============================================================

class DataFrameCleaner(DataCleaner):

    def clean(self, data):

        try:

            df = data.copy()

            original_rows = len(df)
            original_columns = len(df.columns)

            print("\nCleaning data...")
            print(
                f"  Original shape: "
                f"{df.shape}"
            )

            # ------------------------------------------------
            # Step 1: Clean column names
            # ------------------------------------------------

            df.columns = (
                df.columns
                .str.strip()
                .str.lower()
                .str.replace(" ", "_")
            )

            # ------------------------------------------------
            # Step 2: Remove completely empty rows
            # ------------------------------------------------

            df = df.dropna(how="all")

            # ------------------------------------------------
            # Step 3: Convert empty strings to NaN
            # ------------------------------------------------

            df = df.replace(
                r"^\s*$",
                pd.NA,
                regex=True
            )

            # ------------------------------------------------
            # Step 4: Strip text columns
            # ------------------------------------------------

            for column in df.select_dtypes(
                include="object"
            ).columns:

                df[column] = (
                    df[column]
                    .astype("string")
                    .str.strip()
                )

            # ------------------------------------------------
            # Step 5: Remove duplicate rows
            # ------------------------------------------------

            duplicate_count = df.duplicated().sum()

            df = df.drop_duplicates()

            # ------------------------------------------------
            # Step 6: Convert numeric-looking columns
            # ------------------------------------------------

            numeric_candidates = [
                "quantity",
                "unit_price",
                "age",
                "price",
                "amount",
                "salary",
                "income"
            ]

            for column in numeric_candidates:

                if column in df.columns:

                    df[column] = pd.to_numeric(
                        df[column],
                        errors="coerce"
                    )

            # ------------------------------------------------
            # Step 7: Missing-value report
            # ------------------------------------------------

            missing_values = (
                df.isna()
                .sum()
                .sum()
            )

            final_rows = len(df)

            # ------------------------------------------------
            # Quality information
            # ------------------------------------------------

            quality = {
                "original_rows": original_rows,
                "final_rows": final_rows,
                "rows_removed": original_rows - final_rows,
                "original_columns": original_columns,
                "final_columns": len(df.columns),
                "duplicates_removed": int(duplicate_count),
                "missing_values": int(missing_values)
            }

            print(
                f"  Final shape: {df.shape}"
            )

            print(
                f"  Duplicates removed: "
                f"{duplicate_count}"
            )

            print(
                f"  Missing values: "
                f"{missing_values}"
            )

            return df, quality

        except Exception as e:

            raise TransformationError(
                f"Data cleaning failed: {e}"
            )


# ============================================================
# 7. ETL Pipeline
# ============================================================

class ETLPipeline:

    def __init__(
        self,
        sources,
        cleaner
    ):

        self.sources = sources
        self.cleaner = cleaner

    def run(self, output_dir):

        results = []

        os.makedirs(
            output_dir,
            exist_ok=True
        )

        for source in self.sources:

            try:

                # ============================================
                # EXTRACT
                # ============================================

                data = source.load()

                print(
                    f"  Extracted: "
                    f"{data.shape}"
                )

                # ============================================
                # TRANSFORM
                # ============================================

                cleaned_data, quality = (
                    self.cleaner.clean(data)
                )

                # ============================================
                # OUTPUT
                # ============================================

                source_name = (
                    type(source).__name__
                )

                if isinstance(
                    source,
                    CSVSource
                ):

                    file_name = os.path.basename(
                        source.file_path
                    )

                    base_name = os.path.splitext(
                        file_name
                    )[0]

                elif isinstance(
                    source,
                    SQLSource
                ):

                    base_name = (
                        source.table
                    )

                else:

                    base_name = "unknown_source"

                output_file = os.path.join(
                    output_dir,
                    f"cleaned_{base_name}.csv"
                )

                cleaned_data.to_csv(
                    output_file,
                    index=False,
                    encoding="utf-8-sig"
                )

                quality["source"] = (
                    source_name
                )

                quality["output_file"] = (
                    output_file
                )

                results.append(
                    quality
                )

                print(
                    f"  Output: "
                    f"{output_file}"
                )

            except ETLError as e:

                print(
                    f"\nETL ERROR - "
                    f"{type(source).__name__}: "
                    f"{e}"
                )

        # ====================================================
        # Quality Report
        # ====================================================

        if results:

            report = pd.DataFrame(
                results
            )

            report_file = os.path.join(
                output_dir,
                "etl_quality_report.csv"
            )

            report.to_csv(
                report_file,
                index=False,
                encoding="utf-8-sig"
            )

            print(
                "\nQuality report created:"
            )

            print(report)

            print(
                f"\nReport saved to:"
                f"\n{report_file}"
            )


# ============================================================
# 8. Main
# ============================================================

if __name__ == "__main__":

    # --------------------------------------------------------
    # Base folder
    # --------------------------------------------------------

    BASE_DIR = os.path.dirname(
        os.path.abspath(__file__)
    )

    OUTPUT_DIR = os.path.join(
        BASE_DIR,
        "etl_output"
    )

    # --------------------------------------------------------
    # CSV files
    # --------------------------------------------------------

    sales_file = os.path.join(
        BASE_DIR,
        "sales_raw.csv"
    )

    customers_file = os.path.join(
        BASE_DIR,
        "customers_raw.csv"
    )

    marriage_file = os.path.join(
        BASE_DIR,
        "marriage_divorce_eda.csv"
    )

    # --------------------------------------------------------
    # CSV configurations
    # --------------------------------------------------------

    sales_config = {
        "type": "csv",
        "file_path": sales_file
    }

    customers_config = {
        "type": "csv",
        "file_path": customers_file
    }

    marriage_config = {
        "type": "csv",
        "file_path": marriage_file
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
    # Create sources
    # --------------------------------------------------------

    sources = [
        CSVSource.from_dict(
            sales_config
        ),

        CSVSource.from_dict(
            customers_config
        ),

        CSVSource.from_dict(
            marriage_config
        ),

        SQLSource.from_dict(
            sql_config
        )
    ]

    # --------------------------------------------------------
    # Cleaner
    # --------------------------------------------------------

    cleaner = DataFrameCleaner()

    # --------------------------------------------------------
    # Pipeline
    # --------------------------------------------------------

    pipeline = ETLPipeline(
        sources,
        cleaner
    )

    # --------------------------------------------------------
    # Run ETL
    # --------------------------------------------------------

    pipeline.run(
        OUTPUT_DIR
    )