from pathlib import Path

p = Path(__file__).resolve()

print("__file__ :", __file__)
print("resolve :", p)
print("parent  :", p.parent)
print("parent2 :", p.parent.parent)
print("parent3 :", p.parent.parent.parent)
print("parent4 :", p.parent.parent.parent.parent)