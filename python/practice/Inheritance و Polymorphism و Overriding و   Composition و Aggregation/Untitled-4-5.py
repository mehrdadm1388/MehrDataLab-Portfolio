# =========================================================
#  Aggregation + Composition Demo
# =========================================================

# ---------- اجزای Aggregation (از بیرون می‌آیند) ----------
class Loader:
    def __init__(self, source):
        self.source = source

    def load(self):
        return f"Loading data from {self.source}"

    def __str__(self):
        return f"Loader({self.source})"


class Analyzer:
    def __init__(self, method):
        self.method = method

    def analyze(self):
        return f"Analyzing with {self.method}"

    def __str__(self):
        return f"Analyzer({self.method})"


# ---------- جزء Composition (داخل ساخته می‌شود) ----------
class Logger:
    def __init__(self):
        self.messages = []

    def log(self, msg):
        self.messages.append(msg)
        print(f"  [LOG] {msg}")

    def __str__(self):
        return f"Logger({len(self.messages)} messages)"


# =========================================================
#  DataPipeline → Aggregation
# =========================================================
class DataPipeline:
    def __init__(self, loader, analyzer):
        # این دو از بیرون می‌آیند → Aggregation
        self.loader = loader
        self.analyzer = analyzer

    def run(self):
        print("▶ Running pipeline:")
        print("  ", self.loader.load())
        print("  ", self.analyzer.analyze())

    def __str__(self):
        return f"DataPipeline({self.loader}, {self.analyzer})"


# =========================================================
#  Report → Composition (Logger) + Aggregation (Pipeline)
# =========================================================
class Report:
    def __init__(self, pipeline):
        # pipeline از بیرون می‌آید → Aggregation
        self.pipeline = pipeline
        # Logger داخل ساخته می‌شود → Composition
        self.logger = Logger()

    def generate(self):
        self.logger.log("Report generation started.")
        self.pipeline.run()
        self.logger.log("Report generation finished.")
        print(f"  Total logs: {len(self.logger.messages)}")

    def __str__(self):
        return f"Report({self.pipeline})"


# =========================================================
#  اجرا
# =========================================================
if __name__ == "__main__":
    # Aggregation: اجزا مستقل ساخته می‌شوند
    loader = Loader("sales.csv")
    analyzer = Analyzer("groupby + mean")

    # این اجزا به pipeline تزریق می‌شوند
    pipeline = DataPipeline(loader, analyzer)
    print(pipeline)
    print()

    # Report هم pipeline را از بیرون می‌گیرد (Aggregation)
    # و هم Logger را داخل خودش می‌سازد (Composition)
    report = Report(pipeline)
    print(report)
    print()

    report.generate()