import logging
logging.basicConfig(level=logging.ERROR)



class SalesError(Exception):
    pass


class Sale:

    tax_rate = 0.10

    def __init__(self, product, quantity, price):

        if quantity <= 0:
            raise SalesError("Invalid quantity")

        if price < 0:
            raise SalesError("Invalid price")

        self.product = product
        self.quantity = quantity
        self.price = price

    def total(self):
        return self.quantity * self.price

    @classmethod
    def from_dict(cls, row):
        try:
            return cls(
                product=row["product"],
                quantity=int(row["quantity"]),
                price=float(row["price"])
            )
        except (KeyError, ValueError, TypeError) as e:
        
            raise SalesError(f"Data format error: {e}")

rows = [
    {"product": "Laptop", "quantity": "2", "price": "50000"},
    {"product": "Mouse", "quantity": "5", "price": "2000"},
    {"product": "Keyboard", "quantity": "-2", "price": "3000"},
]
def create_sales(data):
    sales = []
    for row in data:
        try:
            sale = Sale.from_dict(row)
            sales.append(sale)
     
       
     
        except (ValueError, TypeError, SalesError) as e:
            logging.error(f"Skipping invalid row {row}: {e}")
            continue 
    return sales

processed_sales = create_sales(rows)

print(f"\nSuccessfully processed {len(processed_sales)} sales:")
for s in processed_sales:
    print(f"Product: {s.product}, Total: {s.total()}")
     