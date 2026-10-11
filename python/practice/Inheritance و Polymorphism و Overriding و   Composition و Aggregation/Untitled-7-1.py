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

    def __init__(self, models):

        self.models = models

    def run(self, data):

        results = {}

        for model in self.models:

            name = type(model).__name__

            results[name] = model.calculate(data)

        return results

macro_data = {
    
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

engine = MacroEngine([
    GDPGrowthModel(),
    InflationChangeModel()
])

results = engine.run(macro_data)

print(results)