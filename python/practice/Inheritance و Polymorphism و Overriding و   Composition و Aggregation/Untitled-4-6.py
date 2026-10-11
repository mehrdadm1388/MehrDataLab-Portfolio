class DataSource:

    def load(self):
        raise NotImplementedError

class CSVSource(DataSource):

    def load(self):
        return "CSV data"


class SQLSource(DataSource):

    def load(self):
        return "SQL data"



class DataPipeline:

    def __init__(self, sources):
        self.sources = sources

    def run(self):

        for source in self.sources:
            print(source.load())

sources = [
    CSVSource(),
    SQLSource()
]

pipeline = DataPipeline(sources)

pipeline.run()

