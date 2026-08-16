""""
#from src.loaddata import df
#from src.validation import *

#
#expected_columns = [
 #   "OrderID",
 #   "OrderDate",
  "CustomerID",
    "CustomerName",
    "City",
    "Category",
    "Product",
    "Quantity",
    "UnitPrice",
    "Discount",
    "Sales",
    "Cost",
    "Profit",
    "Region",
    "Channel",
    "PaymentMethod",
    "SalesPerson"
]


#validate_none(df)

#validate_columns(df, expected_columns)

#validate_primary_key(df, "OrderID")


#print("=" * 60)
#print("DATA VALIDATION REPORT")
#print("=" * 60)

#print(f"Shape : {df.shape}")

#print("\nData Types")
#print(validate_dtypes(df))

#print("\nNull Values")
#print(validate_null(df))

#print("\nDuplicate Rows")
#print(validate_duplicates(df))

#print("\nNegative Values")
#print(validate_negative(
 #   df,
  #  ["Quantity", "UnitPrice", "Sales", "Cost", "Profit"]
))

#print("\nInvalid Dates")
#print(validate_date(df, "OrderDate"))

#print("=" * 60)
"""

from src.loaddata import df

from src.validation import *

from src.analyze import *

from src.exportexcel import *

from src.exportpdf import *

expected_dtypes = {

    "OrderID": "int64",

    "OrderDate": "str",

    "CustomerID": "int64",

    "CustomerName": "str",

    "Gender": "str",

    "Age": "int64",

    "City": "str",

    "Province": "str",

    "Category": "str",

    "Product": "str",

    "Quantity": "int64",

    "UnitPrice": "int64",

    "Sales": "float64",

    "Profit": "float64",

    "PaymentMethod": "str",

    "SalesPerson": "str"
}

validate_none(df)

validate_columns(df, expected_columns)

validate_dtype(df, expected_dtypes)

invalid_count = validate_date(df, "OrderDate") 


print(f"تعداد تاریخ‌های خراب: {invalid_count}")


print(validate_negative(
    df,
    ["Quantity", "UnitPrice", "Sales", "Profit"]
))

print(validate_duplicates(df))

print(validate_null(df))

validate_primary_key(df, "OrderID")

print(basic_information(df))

print(descriptive_statistics(df))

print(categorical_statistics(df))

print(total_sales(df))

print(average_sales(df))

print(sales_by_city(df))

print(sales_by_category(df))

print(validate_dtypes(df))

print(validate_shape(df))



export_excel(df)

export_report("Analysis Completed Successfully")


inconsistent = validate_key_consistency(df, "CustomerID", "CustomerName")

print(f"تعداد CustomerID با نام‌های متفاوت: {inconsistent['CustomerID'].nunique() if not inconsistent.empty else 0}")

if not inconsistent.empty:
    print(inconsistent.head(10))  # نمایش چند نمونه برای مستندسازی




from src.normalize import normalize_dataset

# ... (تمام validate ها و analyze های قبلی بدون تغییر) ...

# --- نرمال‌سازی و خروجی نهایی ---
normalized_tables = normalize_dataset(df)

for name, table in normalized_tables.items():
    print(f"{name}: {table.shape[0]} rows, {table.shape[1]} columns")

export_excel(normalized_tables)