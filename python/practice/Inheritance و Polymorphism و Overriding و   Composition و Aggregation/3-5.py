import logging

class ModelError(Exception):
    pass

class NegativeInputError(ModelError):
    pass

class DivisionError(ModelError):
    pass

class Model:
    def compute(self, x):
        raise NotImplementedError

class SquareRootModel(Model):
    def compute(self, x):
        if x < 0:
            raise NegativeInputError(f"مقدار منفی: {x}")
        return x ** 0.5

class InverseModel(Model):
    def compute(self, x):
        if x == 0:
            raise DivisionError("تقسیم بر صفر")
        return 1 / x

models = [SquareRootModel(), InverseModel(), InverseModel()]
inputs = [4, 0,2]

for m, x in zip(models, inputs):
    try:
        print(type(m).__name__, "->", m.compute(x))
    except ModelError as e:
        logging.exception("خطا در مدل")


