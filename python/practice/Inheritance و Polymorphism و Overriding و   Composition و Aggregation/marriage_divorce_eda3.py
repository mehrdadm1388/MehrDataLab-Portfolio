import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus


# =========================================
# 1. Base Class
# =========================================

class DataSource:

    @classmethod
    def from_dict(cls, row):
        return cls()


# =========================================
# 2. CSV Source
# =========================================

class CSVSource(DataSource):

    def __init__(self, file_path):
        self.file_path = file_path

    @classmethod
    def from_dict(cls, row):
        return cls(row["file_path"])

    def load(self):

        print(f"Loading CSV file: {self.file_path}")

        df = pd.read_csv(self.file_path)

        return df


# =========================================
# 3. SQL Source
# =========================================

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
        print(f"Loading SQL table: {self.database}.{self.table}")

        # ۱. ساخت Connection String
        # نکته: مطمئن شو درایور نصب شده 'ODBC Driver 17 for SQL Server' یا نسخه مشابه باشد
        connection_string = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={self.server};"
            f"DATABASE={self.database};"
            "Trusted_Connection=yes;"
        )

        # ۲. ساخت URL برای SQLAlchemy
        # این فرمت استاندارد برای اتصال mssql از طریق pyodbc است
        connection_url = f"mssql+pyodbc:///?odbc_connect={quote_plus(connection_string)}"

        # ۳. ایجاد Engine و خواندن داده
        engine = create_engine(connection_url)
        query = f"SELECT * FROM {self.table}"
        
        try:
            df = pd.read_sql(query, engine)
            return df
        except Exception as e:
            print(f"Error connecting to SQL Server: {e}")
            return None


# =========================================
# 4. Pipeline
# =========================================

class Pipeline:

    def __init__(self, sources):
        self.sources = sources

    def run(self):

        results = []

        for source in self.sources:

            data = source.load()

            results.append(data)

        return results


# =========================================
# 5. Factory
# =========================================

def create_source(row):

    source_type = row["type"]

    if source_type == "csv":

        return CSVSource.from_dict(row)

    elif source_type == "sql":

        return SQLSource.from_dict(row)

    else:

        raise ValueError(
            f"Unknown source type: {source_type}"
        )


# =========================================
# 6. Configuration
# =========================================

rows = [

    {
        "type": "csv",
        "file_path": "marriage_divorce_eda.csv"
    },

    {
        "type": "sql",
        "server": r".",
        "database": "MehrDataLab",
        "table": "Students"
    }

]


# =========================================
# 7. Create Sources
# =========================================

sources = [

    create_source(row)
    for row in rows

]


# =========================================
# 8. Create Pipeline
# =========================================

pipeline = Pipeline(sources)


# =========================================
# 9. Run
# =========================================

results = pipeline.run()


# =========================================
# 10. Display Results
# =========================================

csv_data = results[0]
students_data = results[1]


print("\n===== Marriage / Divorce Data =====")

print(csv_data.head())


print("\n===== Students Data =====")

print(students_data.head())