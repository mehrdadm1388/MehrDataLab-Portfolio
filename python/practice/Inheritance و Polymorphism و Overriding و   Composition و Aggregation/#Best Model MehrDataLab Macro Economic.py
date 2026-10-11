#Best Model MehrDataLab Macro Economic

import pandas as pd

# 1. Input Data
macro_data = {
    "country": "Iran",
    "gdp": {2022: 350, 2023: 380, 2024: 420, 2025: 450},
    "inflation": {2022: 45, 2023: 40, 2024: 35, 2025: 30},
    "unemployment": {2022: 10, 2023: 9.5, 2024: 9, 2025: 8.5},
    "nominal_interest": {2022: 20, 2023: 23, 2024: 28, 2025: 30}
}

def create_macro_dataframe(data):
    # استخراج سال‌ها از یکی از دیکشنری‌ها (مثلاً gdp)
    years = list(data["gdp"].keys())
    
    # ساخت یک لیست از دیکشنری‌ها برای هر سال
    rows = []
    for year in years:
        row = {
            "Year": year,
            "Country": data["country"],
            "GDP": data["gdp"].get(year),
            "Inflation": data["inflation"].get(year),
            "Unemployment": data["unemployment"].get(year),
            "Nominal_Interest": data["nominal_interest"].get(year)
        }
        rows.append(row)
    
    return pd.DataFrame(rows)

def add_economic_metrics(df):
    # الف) محاسبه نرخ رشد GDP (تفاوت سالانه)
    # pct_change فرمول (current - prev) / prev را خودکار انجام می‌دهد
    df['GDP_Growth_%'] = df['GDP'].pct_change() * 100

    # ب) محاسبه نرخ بهره واقعی (Real Interest = Nominal - Inflation)
    df['Real_Interest'] = df['Nominal_Interest'] - df['Inflation']

    # ج) محاسبه تغییرات تورم (Inflation Change)
    df['Inflation_Change'] = df['Inflation'].diff()

    return df

# --- اجرای فرآیند (Pipeline) ---

# مرحله 1: تبدیل دیکشنری به DataFrame
df = create_macro_dataframe(macro_data)

# مرحله 2: اضافه کردن ستون‌های محاسباتی (Metrics)
df = add_economic_metrics(df)

# مرحله 3: نمایش خروجی نهایی
print("📊 Macro Economic Analysis Table (Pivot-like):")
print(df.to_string(index=False))

# اگر بخواهید خروجی را به اکسل یا CSV بفرستید:
# df.to_csv("macro_report.csv", index=False)
####################################################
macro_data = {
    "country": "Iran",

    "gdp": {
        2022: 350,
        2023: 380,
        2024: 420,
        2025: 450
    },

    "inflation": {
        2022: 45,
        2023: 40,
        2024: 35,
        2025: 30
    },

    "unemployment": {
        2022: 10,
        2023: 9.5,
        2024: 9,
        2025: 8.5
    },

    "nominal_interest": {
        2022: 20,
        2023: 23,
        2024: 28,
        2025: 30
    }
}
df = pd.DataFrame({
    "Year": list(macro_data["gdp"].keys()),
    "GDP": list(macro_data["gdp"].values()),
    "Inflation": list(macro_data["inflation"].values()),
    "Unemployment": list(macro_data["unemployment"].values()),
    "Nominal Interest": list(macro_data["nominal_interest"].values())
})



print(df)

