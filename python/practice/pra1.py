class Product:

    def __init__(self, name, price, category):
        self.name = name
        self.price = price
        self.category = category
    def to_dictp(self):
            return {"name": self.name, "price": self.price, "category": self.category}
    
    def to_listp(self):
            return [self.name, self.price, self.category]
    
p1 = Product("Laptop", 50000, "Computer")
p2 = Product("Mouse", 2000, "Computer")
print(p1)
print(p2)
print(p1 is p2)
print(p1.name)
print(p1.price)
print(p1.category)
print(p1.__dict__) 

print(p2.name)
print(p2.price)
print(p2.category)
print(p2.__dict__) 
    

print(p1.to_dictp()) 
print(p1.to_listp())

class Employee:

    def __init__(self, name, department, salary):
        self.name = name
        self.department = department
        self.salary = salary

    def to_dicte(self):
              return{'name':self.name, 'department':self.department, 'salary':self.salary}
    def to_liste(self):
                  return[self.name, self.department, self.salary]

e1 = Employee("Ali", "Data", 30000)
e2 = Employee("Sara", "Finance", 35000)

print(e1.name)
print(e1.department)
print(e1.salary)

print(e2.name)
print(e2.department)
print(e2.salary)

print(e1.to_dicte()) 
print(e2.to_liste())


class Sale:

    def __init__(self, product, quantity, amount):
        self.product = product
        self.quantity = quantity
        self.amount = amount



   

    def to_dicts(self):
              return{'product':self.product, 'quantity':self.quantity, 'amount':self.amount}
    def to_lists(self):
                  return[self.product, self.quantity, self.amount]
s1 = Sale("Laptop", 2, 100000)
s2 = Sale("Mouse", 10, 20000)

print(s1.to_dicts()) 
print(s2.to_lists())

class Customer:

    def __init__(self, name, city, total_purchase):
        self.name = name
        self.city = city
        self.total_purchase = total_purchase

    def to_dictc(self):
              return{'name':self.name, 'city':self.city, 'total_purchase':self.total_purchase}
    def to_listc(self):
                  return[self.name, self.city, self.total_purchase]
c1 = Customer("Ali", "Tehran", 500000)
c2 = Customer("Sara", "Shiraz", 750000)

print(c1.to_dictc()) 
print(c2.to_listc())

class EconomicIndicator:

    def __init__(self, name, year, value):
        self.name = name
        self.year = year
        self.value = value

    def to_dicte(self):
              return{'name':self.name, 'year':self.year, 'value':self.value}
    def to_liste(self):
                  return[self.name, self.year, self.value]



inflation = EconomicIndicator(
    "Inflation",
    1404,
    35.2
)

unemployment = EconomicIndicator(
    "Unemployment",
    1404,
    8.5
)
print(inflation.to_dicte()) 
print(unemployment.to_liste())

class Sale:

    def __init__(self, product, quantity, amount):
        self.product = product
        self.quantity = quantity
        self.amount = amount

    def to_dicts(self):
              return{'product':self.product, 'quantity':self.quantity, 'amount':self.amount}
sales = [
    Sale("Laptop", 2, 100000),
    Sale("Mouse", 10, 20000),
    Sale("Keyboard", 5, 30000),
]
for sale in sales:
    print(sale.product, sale.quantity, sale.amount)
    print(sale.to_dicts())

class Sale:
    def __init__(self, product, quantity):
        self.product = product
        self.quantity = quantity

def create_sale(product, quantity):
    if quantity <= 0:
        raise ValueError("Invalid quantity")

    return Sale(product, quantity)

sales = []

data = [
    ("Laptop", 2),
    ("Mouse", 5),
    ("Keyboard", -1),
    ("Monitor", 3)
]

for product, quantity in data:
    try:
        sales.append(create_sale(product, quantity))
    except ValueError:
        print("Skipped:", product)

print(len(sales))


data = {
    "name": "Laptop",
    "price": 50000
}

class Product:
    def __init__(self, name, price, category):
        self.name = name
        self.price = price
        self.category = category

p = Product(
    data.get("name"),
    data.get("price"),
    data.get("category", "Unknown")
)

print(p.__dict__)

import logging

class InvalidSaleError(Exception):
    pass


class Sale:
    def __init__(self, product, quantity, price):
        if quantity <= 0:
            raise InvalidSaleError("Invalid quantity")

        self.product = product
        self.quantity = quantity
        self.price = price

    def to_dict(self):
        return {
            "product": self.product,
            "quantity": self.quantity,
            "price": self.price
        }


def create_sales(data):
    sales = []

    for row in data:
        try:
            sale = Sale(
                row.get("product"),
                int(row.get("quantity")),
                float(row.get("price"))
            )

            sales.append(sale)

        except (ValueError, TypeError, InvalidSaleError):
            logging.exception("Invalid row")

    return sales


data = [
    {"product": "Laptop", "quantity": "2", "price": "50000"},
    {"product": "Mouse", "quantity": "5", "price": "2000"},
    {"product": "Keyboard", "quantity": "-1", "price": "3000"},
    {"product": "Monitor", "quantity": "3", "price": "abc"},
    {"product": "CPU", "quantity": "4", "price": "10000"}
]

sales = create_sales(data)

print(len(sales))

for sale in sales:
    print(sale.to_dict())