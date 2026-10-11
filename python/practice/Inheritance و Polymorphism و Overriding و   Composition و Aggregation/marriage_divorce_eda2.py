import pandas as pd 

class DataError(Exception):
    pass


class ConnectionError(DataError):
    pass


class DataSource:

    def load(self):
        raise NotImplementedError


class CSVSource(DataSource):
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


class SQLSource(DataSource):

    def load(self):
        
        raise ConnectionError("SQL connection failed")


class APISource(DataSource):

    def load(self):
        raise ConnectionError("API connection failed")


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
                    f"{type(source).__name__} Error: {e}"
                )

        return results


sources = [
    CSVSource( "marriage_divorce_eda.csv"),
    SQLSource(),
    APISource()
]

pipeline = Pipeline(sources)

print(pipeline.run())