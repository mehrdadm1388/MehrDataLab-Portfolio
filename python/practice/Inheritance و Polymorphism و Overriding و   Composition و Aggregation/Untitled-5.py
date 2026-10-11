import logging

logging.basicConfig(level=logging.ERROR)


# =========================
# Exceptions
# =========================

class SalesError(Exception):
    pass


class InvalidQuantityError(SalesError):
    pass


class InvalidPriceError(SalesError):
    pass


class InvalidShippingCostError(SalesError):
    pass


# =========================
# Parent Class
# =========================

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

    def subtotal(self):
        return self.quantity * self.price

    def total(self):
        return self.subtotal() * (1 + self.tax_rate)

    @classmethod
    def from_dict(cls, row):

        try:
            return cls(
                product=row["product"],
                quantity=int(row["quantity"]),
                price=float(row["price"])
            )

        except (KeyError, ValueError, TypeError) as e:

            raise SalesError(
                f"Data format error: {e}"
            )


# =========================
# OnlineSale
# =========================

class OnlineSale(Sale):

    def __init__(
        self,
        product,
        quantity,
        price,
        shipping_cost
    ):

        super().__init__(
            product,
            quantity,
            price
        )

        if shipping_cost < 0:
            raise InvalidShippingCostError(
                "Shipping cost cannot be negative"
            )

        self.shipping_cost = shipping_cost

    def total(self):

        online_subtotal = (
            self.subtotal()
            + self.shipping_cost
        )

        return online_subtotal * (1 + self.tax_rate)

    @classmethod
    def from_dict(cls, row):

        try:
            return cls(
                product=row["product"],
                quantity=int(row["quantity"]),
                price=float(row["price"]),
                shipping_cost=float(row["shipping_cost"])
            )

        except (KeyError, ValueError, TypeError) as e:

            raise SalesError(
                f"Data format error: {e}"
            )


# =========================
# DiscountSale
# =========================

class DiscountSale(Sale):

    discount_rate = 0.10

    def total(self):

        discounted = (
            self.subtotal()
            * (1 - self.discount_rate)
        )

        return discounted * (1 + self.tax_rate)

    @classmethod
    def from_dict(cls, row):

        try:
            return cls(
                product=row["product"],
                quantity=int(row["quantity"]),
                price=float(row["price"])
            )

        except (KeyError, ValueError, TypeError) as e:

            raise SalesError(
                f"Data format error: {e}"
            )


# =========================
# Factory Function
# =========================

def create_sale(row):

    sale_type = row["type"]

    if sale_type == "sale":
        return Sale.from_dict(row)

    elif sale_type == "online":
        return OnlineSale.from_dict(row)

    elif sale_type == "discount":
        return DiscountSale.from_dict(row)

    else:
        raise SalesError(
            f"Unknown sale type: {sale_type}"
        )


# =========================
# Input Data
# =========================

rows = [

    {
        "type": "sale",
        "product": "Book",
        "quantity": 2,
        "price": 100
    },

    {
        "type": "online",
        "product": "Laptop",
        "quantity": 1,
        "price": 1000,
        "shipping_cost": 50
    },

    {
        "type": "discount",
        "product": "Phone",
        "quantity": 1,
        "price": 800
    },

    {
        "type": "online",
        "product": "Monitor",
        "quantity": 2,
        "price": 300,
        "shipping_cost": 25
    },

    {
        "type": "sale",
        "product": "Mouse",
        "quantity": -2,
        "price": 2000
    },

    {
        "type": "discount",
        "product": "Keyboard",
        "quantity": 1,
        "price": -300
    }
]


# =========================
# Processing
# =========================

for row in rows:

    try:

        sale = create_sale(row)

        print(
            sale.product,
            "=>",
            sale.total()
        )

    except SalesError as e:

        logging.error(
            f"{row.get('product', 'Unknown')} : {e}"
        )