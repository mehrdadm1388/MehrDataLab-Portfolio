class Employee:

    def __init__(self, name):
        self.name = name


class Department:

    def __init__(self, employees):
        self.employees = employees

e1 = Employee("Ali")
e2 = Employee("Reza")

employees = [e1, e2]

department = Department(employees)

print(e1.__dict__)
print(e2.__dict__)
for emp in employees:
    print(emp.name)

names = [emp.name for emp in employees]
print(names)

names_dict = {f"employee{i}": emp.name for i, emp in enumerate(employees, start=1)}
print(names_dict)


result = {f"e{i}": emp.__dict__ for i, emp in enumerate(employees, start=1)}
print(result)