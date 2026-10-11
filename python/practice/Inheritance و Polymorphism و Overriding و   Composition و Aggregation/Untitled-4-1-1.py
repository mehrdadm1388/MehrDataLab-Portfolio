class Employee:

    def __init__(self, name):
        self.name = name


class Department:

    def __init__(self, employees):
        self.employees = employees

    def show_employees(self):
        for employee in self.employees:
            print(employee.name)


e1 = Employee("Ali")
e2 = Employee("Reza")
e3 = Employee("Sara")

department = Department([e1, e2, e3])

department.show_employees()