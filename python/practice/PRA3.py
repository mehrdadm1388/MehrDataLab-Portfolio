import logging

class InvalidSaleError(Exception):
    pass

class Sale:
    def __init__(self, product, quantity):
        if quantity <= 0:
            raise InvalidSaleError("Invalid quantity")

        self.product = product
        self.quantity = quantity

try:
    s = Sale("Laptop", -2)
except InvalidSaleError:
    print("Invalid sale")

class DataError(Exception):
    pass

class SalesError(DataError):
    pass

try:
    raise SalesError()
except DataError:
    print("Data Error")
except SalesError:
    print("Sales Error")


try:
    result = 100 / 0
except Exception:
    logging.exception("Calculation failed")