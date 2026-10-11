import sys
import pandas as pd
from abc import ABC, abstractmethod
import os
from sqlalchemy import create_engine

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
            df = pd.read_csv(self.file_path)
            return df

        except FileNotFoundError:
            raise DataError("CSV file not found")


class SQLSource(DataSource):

    def __init__(self, server, database, table):
        self.server = server
        self.database = database
        self.table = table

    def load(self):
        try:
            driver = "ODBC+Driver+17+for+SQL+Server"
            conn_str = f"mssql+pyodbc://{self.server}/{self.database}?driver={driver}&trusted_connection=yes"
            
            engine = create_engine(conn_str)
            query = f"SELECT * FROM {self.table}"
            return pd.read_sql(query, engine)
            
        except Exception as e:
            raise DataError(f"SQL Connection Error: {e}")


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
                print(
                    f"{type(source).__name__}: {e}"
                )

        return results

if __name__ == "__main__":
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    FILENAME = os.path.join(BASE_DIR, "marriage_divorce_eda.csv")

    sql_config = {
        "server": ".",
        "database": "MehrDataLab",
        "table": "Students"
    }

    sources = [
        CSVSource(FILENAME),
        SQLSource(
            sql_config["server"],
            sql_config["database"],
            sql_config["table"]
        )
    ]

    pipeline = Pipeline(sources)

    results = pipeline.run()

    print("Pipeline completed.")
    print("Number of successful sources:", len(results))

    for i, df in enumerate(results, start=1):
        print(f"\nSource {i}:")
        print(df.head())