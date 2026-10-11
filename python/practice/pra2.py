class Product:

    def __init__(self , name , category , price):
        self.name = name
        self.category = category
        self.price = price

p1 = Product("Laptop", "Computer", 50000)
p2 = Product("Mouse","Computer" , 2000)
print(p1.name)
print(p1.price)
print(p1.category)

print(p2.name)
print(p2.price)
print(p2.category)

class Employee:

    def __init__(self , name ,department ,salary ,
                 experience):
        self.name = name
        self.department = department
        self.salary = salary
        self.experience = experience
Employees=[
        Employee('sara','data', 20000 , 4 ),
        Employee('Ali','sales', 10000 , 5 ),
        Employee('soli','finance', 20000 , 5 ),
        Employee('gholi','Accounting', 15000 , 7 )]
for emp in Employees:
    print(emp.name, emp.department, emp.salary , emp.experience)

class Customer:

    def __init__(self , customer_id ,name ,city ,age ,    customer_type):
        self.customer_id = customer_id
        self.name = name
        self.city = city
        self.age = age
        self.customer_type = customer_type
Customers=[
        Customer(101 , 'sara','tehran', 20 , 'Regular' ),
        Customer(102,'Ali','karaj', 23 , 'vip' ),
        Customer(103,'moli','sary', 21 , 'Regular' ),
        Customer(104,'koli','amol', 20 , 'Regular' ),
        Customer(105,'messy','karaj', 23 , 'vip' )]
for cust in Customers:
    print(cust.customer_id ,cust.name ,cust.city ,cust.age ,  cust.customer_type)


class Sale:

    def __init__(self ,sale_id , product , quantity ,unit_price , city):
        self.sale_id = sale_id
        self.product = product
        self.quantity = quantity
        self.unit_price = unit_price
        self.city = city
        
Sales=[
        Sale(1001 , 'orange','A', 200 , 'AMOL' ),
        Sale(1002,'banana','A', 230 , 'BABOL' ),
        Sale(1003,'apple','B', 210 , 'TEHRAN' ),
        Sale(1004,'water','A', 200 , 'KARAJ' ),
        Sale(1005,'veg','B', 230 , 'GHOM' )]
for sale in Sales:
    print(sale.sale_id ,sale.product ,sale.quantity ,sale.unit_price ,  sale.city)

class InventoryItem:

    def __init__(self, product_id, product_name, category, stock, unit_price):
        self.product_id = product_id
        self.product_name = product_name
        self.category = category
        self.stock = stock
        self.unit_price = unit_price

    def to_listp(self):             
        return [self.product_id , self.product_name, self.category ,self.stock , self.unit_price ]

    def to_dicp(self):             
            return {'product_id':self.product_id , 'product_name' : self.product_name,'category' : self.category , 'stock' :self.stock ,'unit_price' : self.unit_price }

 
    
p1 = InventoryItem(101, "Laptop", "Electronics", 15, 50000)
p2 = InventoryItem(102, "Mouse", "Electronics", 50, 2000)
p3 = InventoryItem(103, "Keyboard", "Electronics", 30, 3000)
p4 = InventoryItem(104, "Chair", "Furniture", 20, 15000)
inventory = [p1, p2, p3, p4]
invlist=[]
invdic=[]
for inv in inventory:
   invlist.append(inv.to_listp()) 
   invdic.append(inv.to_dicp()) 
print(invlist) 
print(invdic)

class Sale:
    def __init__(self, product, quantity):
        self.product = product
        self.quantity = quantity

def total_quantity(*sales):
    total = 0
    for sale in sales:
        total += sale.quantity
    return total

s1 = Sale("Laptop", 2)
s2 = Sale("Mouse", 5)
s3 = Sale("Keyboard", 3)

print(total_quantity(s1, s2, s3))

x = 100

class Product:
    def __init__(self, name):
        self.name = name

def report():
    x = 50

    p = Product("Laptop")

    return x, p.name

print(report())

