
class SalesError(Exception):
    pass


class InvalidQuantityError(SalesError):
    pass


class InvalidPriceError(SalesError):
    pass

class Sale:

    tax_rate = 0.10

    def __init__(self, product,category, quantity, price):
    
            if quantity <= 0:
                raise InvalidQuantityError(
                    "Quantity must be greater than zero"
                )
    
            if price < 0:
                raise InvalidPriceError(
                    "Price cannot be negative"
                )
            self.product = product
            self.category = category
            self.quantity = quantity
            self.unit_price = price
    

    def total (self):
        return self.quantity * self.unit_price

    def total_with_tax(self):
        return (self.quantity * self.unit_price) * (1 + self.tax_rate)

    def to_dict(self):
        return {
            "product": self.product,
            "category": self.category ,
            "quantity": self.quantity,
            "price": self.unit_price
        }
    @classmethod
    def from_dict(cls, row):
   
           try:
               return cls(
                   product=row["product"],
                   category=row["category"],
                   quantity=int(row["quantity"]),
                   price=float(row["price"])
               )
           except (KeyError, ValueError) as e:
   
               raise SalesError(f"Data format error in row: {e}")
rows = [
    {
        "product": "Laptop",
        "category": "Electronics",
        "quantity": "2",
        "price": "50000"
    },
    {
        "product": "Mouse",
        "category": "Electronics",
        "quantity": "5",
        "price": "2000"
    },
    {
        "product": "Keyboard",
        "category": "Electronics",
        "quantity": "3",
        "price": "3000"
    },
    {
        "product": "Monitor",
        "category": "Electronics",
        "quantity": "-1",
        "price": "20000"
    },
    {
        "product": "Desk",
        "category": "Furniture",
        "quantity": "4",
        "price": "10000"
    }
]
def safe_create_sale(row):
    try:
        return Sale.from_dict(row)
    except SalesError as e:
        print(f"⚠️ Skipping product '{row.get('product')}': {e}")
        return None
sales = [s for row in rows if (s := safe_create_sale(row)) is not None]

records = [sale.to_dict() for sale in sales]

import pandas as pd

df = pd.DataFrame(records)
print(df)