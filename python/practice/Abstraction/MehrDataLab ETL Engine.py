from abc import ABC, abstractmethod
import pandas as pd

# ==========================================
# 1. Exceptions
# ==========================================


class ETLError(Exception):
    pass


class ExtractionError(ETLError):
    pass


class TransformationError(ETLError):
    pass


class LoadingError(ETLError):
    pass

# ==========================================
# 2. Abstract Data Source
# ==========================================


class DataSource(ABC):

    @abstractmethod
    def load(self):
        pass

# ==========================================
# 3. CSV Source
# ==========================================


class CSVSource(DataSource):

    def __init__(self, file_path):
        self.file_path = file_path

    def load(self):

        try:
            df = pd.read_csv(self.file_path)

            if df.empty:
                raise ExtractionError(
                    "CSV file is empty"
                )

            return df

        except FileNotFoundError:
            raise ExtractionError(
                f"File not found: {self.file_path}"
            )

# ==========================================
# 4. Abstract Transformer
# ==========================================


class DataTransformer(ABC):

    @abstractmethod
    def transform(self, data):
        pass

# ==========================================
# 5. Sales Transformer
# ==========================================


class SalesTransformer(DataTransformer):

    def transform(self, data):

        try:

            df = data.copy()

            df.columns = (
                df.columns
                .str.strip()
                .str.lower()
            )

            return df

        except Exception as e:

            raise TransformationError(
                str(e)
            )

# ==========================================
# 6. Abstract Loader
# ==========================================


class DataLoader(ABC):

    @abstractmethod
    def load(self, data):
        pass

# ==========================================
# 7. Database Loader
# ==========================================


class DatabaseLoader(DataLoader):

    def load(self, data):

        if data.empty:
            raise LoadingError(
                "No data to load"
            )

        print(
            f"{len(data)} rows loaded successfully"
        )

# ==========================================
# 8. ETL Pipeline
# ==========================================


class ETLPipeline:

    def __init__(
        self,
        source,
        transformer,
        loader
    ):

        # Aggregation
        self.source = source
        self.transformer = transformer
        self.loader = loader

    def run(self):

        try:

            print("1. Extracting...")

            data = self.source.load()

            print("2. Transforming...")

            data = self.transformer.transform(
                data
            )

            print("3. Loading...")

            self.loader.load(data)

            print("ETL completed successfully.")

        except ETLError as e:

            print(
                f"ETL Error: {e}"
            )

# ==========================================
# 9. Build components
# ==========================================


source = CSVSource(
    "marriage_divorce_eda.csv"
)

transformer = SalesTransformer()

loader = DatabaseLoader()

# ==========================================
# 10. Build Pipeline
# ==========================================

pipeline = ETLPipeline(
    source,
    transformer,
    loader
)

# ==========================================
# 11. Run
# ==========================================

pipeline.run()
