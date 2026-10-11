class Product:
    pass

p1 = Product()
p2 = Product()
print(p1)
print(p2)
print(p1 is p2)
p1.name = "Laptop"
p1.price = 50000
p2.name = "Mouse"
p2.price = 2000
print(p1.name)
print(p1.price)

print(p2.name)
print(p2.price)