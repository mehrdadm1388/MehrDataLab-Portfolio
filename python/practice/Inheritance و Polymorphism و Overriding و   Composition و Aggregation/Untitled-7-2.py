class EconomicDataError(Exception):
    pass


class MissingDataError(EconomicDataError):
    pass


class InvalidDataError(EconomicDataError):
    pass

class EconomicDataSource:

    def get_data(self):
        raise NotImplementedError

class IranEconomicDataSource(EconomicDataSource):

    def __init__(self, data):
        self.data = data

    def get_data(self):

        if not self.data:
            raise MissingDataError(
                "Economic data is empty"
            )

        return self.data

class MacroModel:

    def calculate(self, data):
        raise NotImplementedError

class GDPGrowthModel(MacroModel):

    def calculate(self, data):

        years = sorted(data["GDP"])

        results = {}

        for i in range(1, len(years)):

            previous = data["GDP"][years[i - 1]]
            current = data["GDP"][years[i]]

            growth = (
                (current - previous)
                / previous
                * 100
            )

            results[years[i]] = growth

        return results

class InflationChangeModel(MacroModel):

    def calculate(self, data):

        years = sorted(data["Inflation"])

        results = {}

        for i in range(1, len(years)):

            previous = data["Inflation"][years[i - 1]]
            current = data["Inflation"][years[i]]

            results[years[i]] = current - previous

        return results

class MacroEngine:

    def __init__(self, source, models):

        self.source = source
        self.models = models

    def run(self):

        data = self.source.get_data()

        results = {}

        for model in self.models:

            name = type(model).__name__

            try:

                results[name] = model.calculate(data)

            except EconomicDataError as e:

                results[name] = {
                    "error": str(e)
                }

        return results


macro_data = {

     "country": "Iran",
    "GDP": {
        2022: 350,
        2023: 380,
        2024: 420,
        2025: 450
    },

    "Inflation": {
        2022: 45,
        2023: 40,
        2024: 35,
        2025: 30
    }
}

source = IranEconomicDataSource(macro_data)

models = [
    GDPGrowthModel(),
    InflationChangeModel()
]

engine = MacroEngine(
    source,
    models
)

results = engine.run()

print(results)