import logging


logging.basicConfig(level=logging.ERROR)

class SalesError(Exception):

    pass

class Sale:
    tax_rate = 0.10  # Class Attribute

    def __init__(self, product, quantity, price):
        if quantity <= 0:
            raise SalesError(f"Invalid quantity: {quantity}")
        if price < 0:
            raise SalesError(f"Invalid price: {price}")

        self.product = product
        self.quantity = quantity
        self.price = price

    def total(self):

        return (self.quantity * self.price) * (1 + self.tax_rate)

    @classmethod
    def from_dict(cls, row):

        try:
            return cls(
                product=row["product"],
                quantity=int(row["quantity"]),
                price=float(row["price"])
            )
        except (KeyError, ValueError) as e:

            raise SalesError(f"Data format error in row: {e}")


rows = [
    {"product": "Laptop", "quantity": "2", "price": "50000"},
    {"product": "Mouse", "quantity": "5", "price": "2000"},
    {"product": "Keyboard", "quantity": "-2", "price": "3000"},
    {"product": "Monitor", "quantity": "1", "price": "15000"},
]

def create_sales(data):
    sales = []
    for row in data:
        try:

            sale = Sale.from_dict(row)
            sales.append(sale)
        except (ValueError, TypeError, SalesError) as e:

            logging.error(f"Skipping invalid row: {row} | Error: {e}")
            
    return sales


all_sales = create_sales(rows)

print("\n--- Valid Sales ---")
for s in all_sales:
    print(f"Product: {s.product}, Total (with tax): {s.total():.2f}")
