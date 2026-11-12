
import pandas as pd


def inspect_data(table_name, df):

    print(f"\n{'=' * 60}")
    print(f"INSPECTING TABLE: {table_name.upper()}")
    print(f"{'=' * 60}")

    # 1. Basic information
    rows, cols = df.shape

    print("\n[1] BASIC INFORMATION")
    print(f"Total Rows: {rows}")
    print(f"Total Columns: {cols}")
    print(f"Column Names: {list(df.columns)}")

    # 2. Data types
    print("\n[2] DATA TYPES")
    print(df.dtypes)

    # 3. Missing values
    print("\n[3] MISSING VALUES")
    missing_counts = df.isnull().sum()
    missing_percentage = (missing_counts / len(df) * 100) if len(df) else missing_counts

    missing_report = pd.DataFrame({
        "Missing Count": missing_counts,
        "Missing Percentage": missing_percentage.round(2)
    })

    print(missing_report)

    # 4. Duplicate records
    print("\n[4] DUPLICATE RECORDS")
    duplicate_count = df.duplicated().sum()
    print(f"Total Duplicate Rows: {duplicate_count}")

    # 5. Unique values
    print("\n[5] UNIQUE VALUES")
    for column in df.select_dtypes(include=["object", "category"]).columns:
        print(f"\n{column}:")
        print(f"Unique Count: {df[column].nunique(dropna=False)}")
        print(df[column].value_counts(dropna=False).head(10))

    # 6. Statistical summary
    print("\n[6] STATISTICAL SUMMARY")
    print(df.describe(include="all").T)

    # 7. Sample records
    print("\n[7] SAMPLE RECORDS")
    print(df.head())
