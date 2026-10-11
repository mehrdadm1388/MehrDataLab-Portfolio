from abc import ABC, abstractmethod


class Extractor(ABC):

    @abstractmethod
    def extract(self):
        pass


class Transformer(ABC):

    @abstractmethod
    def transform(self, data):
        pass


class Loader(ABC):

    @abstractmethod
    def load(self, data):
        pass
    
class CSVExtractor(Extractor):

    def extract(self):
        return ["100", "200", "300"]


class SalesTransformer(Transformer):

    def transform(self, data):
        return [int(x) for x in data]


class DatabaseLoader(Loader):

    def load(self, data):
        print("Loading to database:", data)
        
class ETLPipeline:

    def __init__(
        self,
        extractor,
        transformer,
        loader
    ):
        self.extractor = extractor
        self.transformer = transformer
        self.loader = loader

    def run(self):

        data = self.extractor.extract()

        data = self.transformer.transform(
            data
        )

        self.loader.load(data)
        
pipeline = ETLPipeline(
    CSVExtractor(),
    SalesTransformer(),
    DatabaseLoader()
)

pipeline.run()