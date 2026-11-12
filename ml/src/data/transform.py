
from ml.src.data.clean import clean_data
from ml.src.data.extract import extract_tables
from ml.src.data.inspect import inspect_data
from ml.src.data.validate import validate_data


def transform_tables():

    # 1. Extract
    all_tables = extract_tables()

    # 2. Inspect, clean, and prepare cleaned tables
    cleaned_tables = {}

    for table_name, df in all_tables.items():

        print(f"\nProcessing table: {table_name}")

        inspect_data(table_name, df)

        cleaned_df = clean_data(table_name, df)

        cleaned_tables[table_name] = cleaned_df

    # 3. Validate after all tables have been cleaned
    all_validation_issues = []

    for table_name, df in cleaned_tables.items():

        print(f"\nValidating table: {table_name}")

        issues = validate_data(
            table_name,
            df,
            cleaned_tables
        )

        all_validation_issues.extend(issues)

    return {
        "raw_tables": all_tables,
        "cleaned_tables": cleaned_tables,
        "validation_issues": all_validation_issues,
    }


if __name__ == "__main__":
    results = transform_tables()
    print("\nTransformation completed.")
