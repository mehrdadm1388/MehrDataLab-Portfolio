class Analyst:
    def __init__(self, name):
        self.name = name

class AnalyticsTeam:
    def __init__(self, analysts):
        self.analysts = list(analysts)  # کپی می‌کنیم تا لیست اصلی دست‌نخورده بماند

    def add_analyst(self, analyst):
        self.analysts.append(analyst)

    def remove_analyst(self, name):
        self.analysts = [a for a in self.analysts if a.name != name]

    def get_names(self):
        return [a.name for a in self.analysts]

    def count(self):
        return len(self.analysts)

    def find_by_name(self, name):
        for a in self.analysts:
            if a.name == name:
                return a
        return None

    def __str__(self):
        return f"تیم تحلیل با {self.count()} عضو: {', '.join(self.get_names())}"
a1 = Analyst("Ali")
a2 = Analyst("Reza")
a3 = Analyst("Sara")
Members = [a1, a2, a3]

team = AnalyticsTeam(Members)

print(team.get_names())        # ['Ali', 'Reza', 'Sara']
print(team.count())            # 3
print(team.find_by_name("Reza"))  # <__main__.Analyst object at ...>

team.add_analyst(Analyst("Mina"))
print(team)                    # تیم تحلیل با 4 عضو: Ali, Reza, Sara, Mina

team.remove_analyst("Ali")
print(team.get_names())        # ['Reza', 'Sara', 'Mina']