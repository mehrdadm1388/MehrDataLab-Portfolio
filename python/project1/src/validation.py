import pandas as pd

def validate_none(df: pd.DataFrame) -> None:
    """
    بررسی می‌کند DataFrame خالی نباشد.
    """
    if df is None or df.empty:
        raise ValueError("DataFrame is None or empty")

def validate_dtype(
    df: pd.DataFrame,
    expected_dtypes: dict
) -> None:
    """
    بررسی نوع داده ستون‌ها.

    Parameters
    ----------
    df : pd.DataFrame
        دیتافریم ورودی.

    expected_dtypes : dict
        دیکشنری شامل نوع مورد انتظار هر ستون.
        مثال:
        {
            "OrderID": "int64",
            "Sales": "float64",
            "OrderDate": "datetime64[ns]"
        }

    Raises
    ------
    ValueError
        اگر نوع داده یکی از ستون‌ها با مقدار مورد انتظار متفاوت باشد.
    """

    errors = []

    for column, expected_dtype in expected_dtypes.items():

        if column not in df.columns:
            errors.append(
                f"Column '{column}' not found."
            )
            continue

        actual_dtype = str(df[column].dtype)

        if actual_dtype != expected_dtype:
            errors.append(
                f"{column}: expected {expected_dtype}, got {actual_dtype}"
            )

    if errors:
        raise ValueError(
            "\n".join(errors)
        )
 
expected_columns = [
    "OrderID",
    "OrderDate",
    "CustomerID",
    "CustomerName",
    "Gender",
    "Age",
    "City",
    "Province",
    "Category",
    "Product",
    "Quantity",
    "UnitPrice",
    "Sales",
    "Profit",
    "PaymentMethod",
    "SalesPerson"
]

def validate_columns(df, expected_columns) -> None:
    """
    بررسی وجود تمام ستون‌های مورد انتظار.
    """
    missing_columns = list(set(expected_columns) - set(df.columns))

    if missing_columns:
        raise ValueError(
            f"Missing columns: {missing_columns}"
        )


def validate_null(df: pd.DataFrame) -> pd.Series:
    """
    تعداد مقادیر Null هر ستون را برمی‌گرداند.
    """
    return df.isnull().sum()


def validate_duplicates(df: pd.DataFrame) -> int:
    """
    تعداد رکوردهای تکراری را برمی‌گرداند.
    """
    return df.duplicated().sum()


def validate_primary_key(df: pd.DataFrame, column: str) -> None:
    """
    بررسی یکتا بودن کلید اصلی.
    """
    if df[column].duplicated().any():
        raise ValueError(
            f"Duplicate values found in '{column}'"
        )


def validate_negative(df: pd.DataFrame, columns: list) -> dict:
    """
    ستون‌هایی که دارای مقدار منفی هستند را برمی‌گرداند.
    """

    result = {}

    for column in columns:

        negative_count = (df[column] < 0).sum()

        result[column] = negative_count

    return result


def validate_date(df: pd.DataFrame, column: str) -> int:
    """
    تعداد تاریخ‌های نامعتبر را برمی‌گرداند.
    """

    invalid_dates = pd.to_datetime(
        df[column],
        errors="coerce"
    ).isnull().sum()

    return invalid_dates


def validate_dtypes(df: pd.DataFrame) -> pd.Series:
    """
    نوع داده هر ستون را برمی‌گرداند.
    """
    return df.dtypes

def validate_shape(df: pd.DataFrame) -> tuple[int, int]:
    """
    تعداد سطر و ستون DataFrame را برمی‌گرداند.
    """

    return df.shape


   

def validate_key_consistency(df: pd.DataFrame, key_col: str, value_col: str) -> pd.DataFrame:
    grouped = df.groupby(key_col)[value_col].nunique()
    violations = grouped[grouped > 1]
    return df[df[key_col].isin(violations.index)][[key_col, value_col]].drop_duplicates()
