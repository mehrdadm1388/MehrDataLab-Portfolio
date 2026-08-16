from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[3]

FILE_PATH = BASE_DIR / "data" / "MehrDataLab_Retail_Dataset.xlsx"

df = pd.read_excel(FILE_PATH)