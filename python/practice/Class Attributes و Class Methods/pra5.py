class Product:
    def add_taxes(self, *tax_rates):
        print(f"Type of tax_rates: {type(tax_rates)}")
        print(f"Content of tax_rates: {tax_rates}")
        
     
        total_tax = sum(tax_rates)
        return total_tax

p = Product()


p.add_taxes(0.05) 

p.add_taxes(0.05, 0.10, 0.02) 
print(p.add_taxes(0.05, 0.10, 0.02))



p.add_taxes() 


def apply_discount( **kwargs):
    print(f"Type: {type(kwargs)}")
    print(f"Content: {kwargs}")

apply_discount(reason="فصلی", discount_amount=500, user="mehdi")


class DiscountManager:
    def apply_discount(self, **kwargs): # self اینجا لازم است چون داخل کلاس است
        print(f"Type: {type(kwargs)}")
        print(f"Content: {kwargs}")


manager = DiscountManager()


manager.apply_discount(reason="فصلی", discount_amount=500, user="mehdi")

def add_sale(total, amount):
    return total + amount

total = 0

total = add_sale(total, 10000)
total = add_sale(total, 20000)
print(total)


def outer():

    x = 10

    def inner():
        print(x)

    inner()

outer()




x = 100

def outer():
    x = 50

    def inner():
        nonlocal x
        x += 1
        print(x)

    inner()
    print(x)

outer()
print(x)




x = 100

def outer():
    x = 50

    def inner():
        global x
        x += 1
        print(x)

    inner()
    print(x)

outer()
print(x)


def make_counter():

    count = 0

    def increment():
        nonlocal count
        count += 1
        return count

    return increment

counter = make_counter()

print(counter())
print(counter())
print(counter())

total_sales = 0


x = "Global"

def outer():

    x = "Enclosing"

    def inner():

        x = "Local"

        print(x)

    inner()

outer()

x = "Global"

def outer():

    x = "Enclosing"

    def inner():

     

        print(x)

    inner()

outer()


x = "Global"

def outer():

   

    def inner():

       

        print(x)

    inner()

outer()