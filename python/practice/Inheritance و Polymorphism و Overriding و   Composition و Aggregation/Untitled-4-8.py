class DataError(Exception):
    pass

class DataSource:

    def load(self):
        raise NotImplementedError

class Pipeline:

    def __init__(self, sources):
        self.sources = sources

    def run(self):

        results = []

        for source in self.sources:

            try:
                results.append(source.load())

            except DataError as e:
                print(f"Error: {e}")

        return results

# ۱. حالا یک منبع واقعی برای CSV می‌سازیم
class CSVSource(DataSource):
    def load(self):
        return "Data from CSV"

# ۲. یک منبع خراب که خطا می‌دهد می‌سازیم
class BrokenSource(DataSource):
    def load(self):
        # فرض کن در این فایل یک ستون مفقود است
        raise DataError("Column 'Age' is missing in CSV!")

# ۳. اجرای Pipeline
sources = [CSVSource(), BrokenSource()]
pipeline = Pipeline(sources)

final_data = pipeline.run()
print("Final Results:", final_data)
