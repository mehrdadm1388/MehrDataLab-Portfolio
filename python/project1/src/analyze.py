import pandas as pd


def basic_information(df):

    return {
        "rows": df.shape[0],
        "columns": df.shape[1]
    }


def descriptive_statistics(df):

    return df.describe()


def categorical_statistics(df):

    return df.describe(include=["object", "string"])


def correlation(df):

    return df.corr(numeric_only=True)


def top_sales(df):

    return df.sort_values(
        by="Sales",
        ascending=False
    ).head(10)


def total_sales(df):

    return df["Sales"].sum()


def average_sales(df):

    return df["Sales"].mean()


def sales_by_city(df):

    return (
        df
        .groupby("City")["Sales"]
        .sum()
        .sort_values(ascending=False)
    )


def sales_by_category(df):

    return (
        df
        .groupby("Category")["Sales"]
        .sum()
    )