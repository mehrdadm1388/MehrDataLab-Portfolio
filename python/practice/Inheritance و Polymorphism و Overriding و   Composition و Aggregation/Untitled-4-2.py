class Analyst:

    def __init__(self, name):
        self.name = name

class AnalyticsTeam:

    def __init__(self, analysts):
        self.analysts = analysts

a1 = Analyst("Ali")
a2 = Analyst("Reza")
a3 = Analyst("Sara")
Members = [a1, a2, a3]
team = AnalyticsTeam(Members)

print({f'analyst{i}':analy.name for i, analy  in enumerate(Members , start=1)})
