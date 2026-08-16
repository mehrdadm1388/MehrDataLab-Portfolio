from pathlib import Path
import pandas as pd

project_root = Path(__file__).resolve().parents[3]
file_path = project_root / "data" / "MehrDataLab_Retail_Dataset.xlsx"

df = pd.read_excel(file_path)

print(df.head())