class CSVSource:

    def load(self):
        return "CSV"


class APISource:

    def load(self):
        return "API"


class SQLSource:

    def load(self):
        return "SQL"

sources = [
    CSVSource(),
    APISource(),
    SQLSource()
]

class Pipeline:

    def __init__(self, sources):
        self.sources = sources

    def run(self):

        for source in self.sources:
            print(source.load())

Pipeline = Pipeline(sources)

Pipeline.run()