# 1. Import dependencies and functions
from ml.src.data.extract import extract_tables
from ml.src.data.inspect import inspect_data
from ml.src.data.clean import clean_data
from ml.src.data.validate import validate_data
from sqlalchemy import create_engine, text

# 2. Define the transformation pipeline
def transform_tables(tables):

    db_url = "postgresql+psycopg2://liz:password@localhost:5442/fraud_guard_live"
    engine = create_engine(db_url)

    cleaned_tables = {}

    all_tables = extract_tables()

    # 3. Process each extracted table
    for table_name, df in all_tables.items():

        # Inspect the original DataFrame

        # Clean the DataFrame

        # Validate the cleaned DataFrame

        # Store the cleaned DataFrame
        # cleaned_tables[table_name] = cleaned_df

    # 4. Return all cleaned DataFrames
    return cleaned_tables


# 5. Run the pipeline
if __name__ == "__main__":

    # Extract tables from PostgreSQL

    # Transform extracted tables

    # Display transformation results