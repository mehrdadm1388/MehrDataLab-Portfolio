from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT = BASE_DIR / "outputs" / "clean_data.xlsx"


def export_excel(data) -> None:
    """
    خروجی اکسل می‌گیرد.
    - اگر data یک DataFrame باشد -> یک شیت (Sheet1)
    - اگر data یک dict از DataFrame ها باشد -> هر کلید = یک شیت جدا
    """
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    with pd.ExcelWriter(OUTPUT, engine="openpyxl") as writer:
        if isinstance(data, dict):
            for sheet_name, df in data.items():
                df.to_excel(writer, sheet_name=sheet_name[:31], index=False)  # حداکثر ۳۱ کاراکتر مجاز اکسل
        else:
            data.to_excel(writer, sheet_name="Sheet1", index=False)

    print(f"Excel file saved successfully:\n{OUTPUT}")