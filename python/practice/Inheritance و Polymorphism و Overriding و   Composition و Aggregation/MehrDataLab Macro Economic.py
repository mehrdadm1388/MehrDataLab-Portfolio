#MehrDataLab Macro Economic
def calculate_gdp_growth(current_gdp, previous_gdp):

    return (
        (current_gdp - previous_gdp)
        / previous_gdp
    ) * 100

def calculate_real_interest(
    nominal_rate,
    inflation
):

    return nominal_rate - inflation

def calculate_unemployment(
    unemployed,
    labor_force
):

    return (
        unemployed / labor_force
    ) * 100


def calculate_inflation_change(
    current_inflation,
    previous_inflation
):

    return (
        current_inflation
        - previous_inflation
    )

class MacroModel:

    def __init__(self, name):
        self.name = name

    def calculate(self):
        raise NotImplementedError

class GDPGrowthModel(MacroModel):

    def __init__(
        self,
        name,
        current_gdp,
        previous_gdp
    ):
        super().__init__(name)

        self.current_gdp = current_gdp
        self.previous_gdp = previous_gdp

    def calculate(self):

        return calculate_gdp_growth(
            self.current_gdp,
            self.previous_gdp
        )

class RealInterestModel(MacroModel):

    def __init__(
        self,
        name,
        nominal_rate,
        inflation
    ):
        super().__init__(name)

        self.nominal_rate = nominal_rate
        self.inflation = inflation

    def calculate(self):

        return calculate_real_interest(
            self.nominal_rate,
            self.inflation
        )

class InflationChangeModel(MacroModel):

    def __init__(
        self,
        name,
        current_inflation,
        previous_inflation
    ):
        super().__init__(name)

        self.current_inflation = current_inflation
        self.previous_inflation = previous_inflation

    def calculate(self):

        return calculate_inflation_change(
            self.current_inflation,
            self.previous_inflation
        )

class UnemploymentModel(MacroModel):

    def __init__(
        self,
        name,
        unemployed,
        labor_force
    ):
        super().__init__(name)

        self.unemployed = unemployed
        self.labor_force = labor_force

    def calculate(self):

        return calculate_unemployment(
            self.unemployed,
            self.labor_force
        )

models = [

    GDPGrowthModel(
        "GDP Growth",
        450,
        420
    ),

    RealInterestModel(
        "Real Interest Rate",
        30,
        30
    ),

    InflationChangeModel(
        "Inflation Change",
        30,
        35
    ),

    UnemploymentModel(
        "Unemployment",
        8.5,
        100
    )
]


class MacroModelError(Exception):
    pass


class InvalidGDPError(MacroModelError):
    pass


class InvalidInflationError(MacroModelError):
    pass


def calculate_gdp_growth(
    current_gdp,
    previous_gdp
):

    if previous_gdp <= 0:
        raise InvalidGDPError(
            "Previous GDP must be greater than zero"
        )

    return (
        (current_gdp - previous_gdp)
        / previous_gdp
    ) * 100

try:

    result = calculate_gdp_growth(
        450,
        0
    )

except MacroModelError as e:

    print(
        "Model Error:",
        e
    )

def run_models(models):

    results = []

    for model in models:

        try:

            value = model.calculate()

            results.append({
                "model": model.name,
                "value": value
            })

        except MacroModelError as e:

            results.append({
                "model": model.name,
                "value": None,
                "error": str(e)
            })

    return results

results = run_models(models)

for result in results:
    print(result)

# MehrDataLab Macro Economic - Optimized Version

class MacroModelError(Exception): pass
class InvalidGDPError(MacroModelError): pass

class MacroModel:
    def __init__(self, name):
        self.name = name

    def calculate(self):
        raise NotImplementedError

class GDPGrowthModel(MacroModel):
    def __init__(self, name, current, previous):
        super().__init__(name)
        self.current, self.previous = current, previous

    def calculate(self):
        if self.previous <= 0:
            raise InvalidGDPError("Previous GDP must be > 0")
        return ((self.current - self.previous) / self.previous) * 100

class RealInterestModel(MacroModel):
    def __init__(self, name, nominal, inflation):
        super().__init__(name)
        self.nominal, self.inflation = nominal, inflation

    def calculate(self):
        return self.nominal - self.inflation

class InflationChangeModel(MacroModel):
    def __init__(self, name, current, previous):
        super().__init__(name)
        self.current, self.previous = current, previous

    def calculate(self):
        return self.current - self.previous

class UnemploymentModel(MacroModel):
    def __init__(self, name, unemployed, labor_force):
        super().__init__(name)
        self.unemployed, self.labor_force = unemployed, labor_force

    def calculate(self):
        return (self.unemployed / self.labor_force) * 100

# --- Execution ---
models = [
    GDPGrowthModel("GDP Growth", 450, 0), # این مدل خطا می‌دهد
    RealInterestModel("Real Interest", 30, 30),
    InflationChangeModel("Inflation Change", 30, 35),
    UnemploymentModel("Unemployment", 8.5, 100)
]

def run_models(models):
    results = []
    for model in models:
        try:
            results.append({"model": model.name, "value": model.calculate()})
        except Exception as e: # گرفتن هر نوع خطای احتمالی
            results.append({"model": model.name, "value": None, "error": str(e)})
    return results

for res in run_models(models):
    print(res)
