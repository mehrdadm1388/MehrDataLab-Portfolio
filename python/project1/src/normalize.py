import pandas as pd


def resolve_canonical_attributes(
    df: pd.DataFrame,
    key_col: str,
    attribute_cols: list,
    order_col: str | None = None,
) -> pd.DataFrame:
    """
    برای هر مقدار key_col، «اولین» مقدار مشاهده‌شده را برای هر ستون
    در attribute_cols انتخاب می‌کند (بر اساس order_col در صورت وجود).

    نوشته شده به‌صورت عمومی تا در پروژه‌های دیگر هم فقط با تغییر
    نام آرگومان‌ها (key_col / attribute_cols / order_col) قابل استفاده باشد.

    اگر order_col داده نشود یا تبدیل به تاریخ ممکن نباشد، ترتیب اصلی
    ردیف‌های فایل به‌عنوان معیار «اول بودن» استفاده می‌شود.
    """
    work = df.copy()
    work["_original_order"] = range(len(work))

    if order_col and order_col in work.columns:
        work["_sort_date"] = pd.to_datetime(work[order_col], errors="coerce")
        work = work.sort_values(
            by=["_sort_date", "_original_order"],
            na_position="last",   # رکوردهای بدون تاریخ معتبر، آخر می‌روند نه اول
            kind="stable",
        )
    else:
        work = work.sort_values("_original_order", kind="stable")

    dim = (
        work
        .groupby(key_col, sort=False)[attribute_cols]
        .first()
        .reset_index()
    )
    return dim


def build_customer_dimension(
    df: pd.DataFrame,
    key_col: str = "CustomerID",
    name_col: str = "CustomerName",
    order_col: str = "OrderDate",
    extra_attrs: list | None = None,
) -> pd.DataFrame:
    """
    جدول بعد مشتریان: برای هر CustomerID فقط یک CustomerName
    (قدیمی‌ترین رکورد بر اساس OrderDate) نگه می‌دارد.
    """
    attrs = [name_col] + (extra_attrs or [])
    return resolve_canonical_attributes(df, key_col, attrs, order_col)


def build_geography_dimension(
    df: pd.DataFrame,
    city_col: str = "City",
    province_col: str = "Province",
) -> pd.DataFrame:
    """
    جدول بعد جغرافیا. City/Province را از جدول مشتریان جدا می‌کند
    تا وابستگی گذرا (City -> Province) نقض 3NF نباشد.
    """
    geo = df[[city_col, province_col]].drop_duplicates().reset_index(drop=True)
    geo.insert(0, "GeoID", range(1, len(geo) + 1))
    return geo


def build_product_dimension(
    df: pd.DataFrame,
    product_col: str = "Product",
    category_col: str = "Category",
) -> pd.DataFrame:
    """
    جدول بعد محصولات. Category به Product وابسته است، نه به هر سفارش.
    """
    products = df[[product_col, category_col]].drop_duplicates().reset_index(drop=True)
    products.insert(0, "ProductID", range(1, len(products) + 1))
    return products


def build_fact_table(
    df: pd.DataFrame,
    products: pd.DataFrame,
    geography: pd.DataFrame,
    customer_key: str = "CustomerID",
    order_key: str = "OrderID",
    order_date: str = "OrderDate",
    product_col: str = "Product",
    category_col: str = "Category",
    city_col: str = "City",
    province_col: str = "Province",
) -> pd.DataFrame:
    """
    جدول واقعیت (Fact Table): متن‌های تکراری (Product, City, ...)
    با کلیدهای خارجی ProductID و GeoID جایگزین می‌شوند.
    """
    fact = df.copy()
    fact[order_date] = pd.to_datetime(fact[order_date], errors="coerce")

    fact = fact.merge(products, on=[product_col, category_col], how="left")
    fact = fact.merge(geography, on=[city_col, province_col], how="left")

    columns = [
        order_key, order_date, customer_key,
        "ProductID", "GeoID",
        "Quantity", "UnitPrice", "Sales", "Profit",
        "PaymentMethod", "SalesPerson",
    ]
    return fact[columns]


def normalize_dataset(df: pd.DataFrame) -> dict:
    """
    پایپ‌لاین کامل نرمال‌سازی. خروجی دیکشنری‌ای از DataFrame هاست
    که هرکدام یک شیت جدا در فایل اکسل خروجی می‌شوند.
    """
    geography = build_geography_dimension(df)
    products = build_product_dimension(df)

    customers = build_customer_dimension(
        df,
        extra_attrs=["Gender", "Age", "City", "Province"],
    )
    # City/Province در جدول مشتری با GeoID جایگزین می‌شود (حذف وابستگی گذرا)
    customers = (
        customers
        .merge(geography, on=["City", "Province"], how="left")
        .drop(columns=["City", "Province"])
    )

    fact_sales = build_fact_table(df, products, geography)

    return {
        "Fact_Sales": fact_sales,
        "Dim_Customers": customers,
        "Dim_Products": products,
        "Dim_Geography": geography,
    }