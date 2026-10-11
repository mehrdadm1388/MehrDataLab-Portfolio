class SalesError(Exception):
    pass


class InvalidQuantityError(SalesError):
    pass


class InvalidPriceError(SalesError):
    pass

class Sale:

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
        self.unit_price = price

    def total_amount(self):
        return self.quantity * self.unit_price

    def to_dict(self):
        return {
            "product": self.product,
            "quantity": self.quantity,
            "unit_price": self.unit_price,
            "amount": self.total_amount()
        }

def create_sale(row):

    try:
        return Sale(
            row.get("product"),
            int(row.get("quantity")),
            float(row.get("price"))
        )

    except (ValueError, SalesError) as e:
        print("Invalid data:", row)
        print("Reason:", e)
        return None

rows = [
    {"product": "Laptop", "quantity": "2", "price": "50000"},
    {"product": "Mouse", "quantity": "5", "price": "2000"},
    {"product": "Keyboard", "quantity": "-1", "price": "3000"},
    {"product": "Monitor", "quantity": "3", "price": "abc"}
]

sales = []

for row in rows:
    sale = create_sale(row)

    if sale is not None:
        sales.append(sale)




import pandas as pd

df = pd.DataFrame([sale.to_dict() for sale in sales])


print(df)