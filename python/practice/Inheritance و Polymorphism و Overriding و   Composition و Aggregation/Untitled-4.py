class SalesError(Exception):
    pass


class InvalidQuantityError(SalesError):
    pass


class InvalidPriceError(SalesError):
    pass

class Sale:

    tax_rate = 0.10

    def __init__(self, product, quantity, price):

        if quantity <= 0:
            raise InvalidQuantityError(
                "Quantity must be greater than zero"
            )

        if price < 0:
            raise InvalidPriceError(
                "Price cannot be negative"
            )

        self.product = product
        self.quantity = quantity
        self.price = price

    def total(self):
        return self.quantity * self.price

class OnlineSale(Sale):

    shipping_rate = 0.05

    def __init__(self, product, quantity, price, shipping_cost):

        super().__init__(product, quantity, price)

        if shipping_cost < 0:
            raise ValueError("Shipping cost cannot be negative")

        self.shipping_cost = shipping_cost

    def total(self):
        return super().total() + self.shipping_cost


class DiscountSale(Sale):

    def total(self):
        return super().total() * 0.9

sales = [
    Sale("Book", 2, 100),
    OnlineSale("Laptop", 1, 1000, 50),
    DiscountSale("Phone", 1, 800)
]

for sale in sales:
    print(sale.total())