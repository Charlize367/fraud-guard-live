
import pandas as pd
from sqlalchemy import create_engine, text


def extract_tables():

    # 1. Set up database connection
    db_url = "postgresql+psycopg2://liz:password@localhost:5432/fraud_guard_live"
    engine = create_engine(db_url)

    # 2. Dictionary to hold all extracted DataFrames
    all_tables = {}

    with engine.connect() as connection:

        # 3. Retrieve all table names from the public schema
        table_query = text("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_type = 'BASE TABLE';
        """)

        result = connection.execute(table_query)
        table_names = [row[0] for row in result]

        # 4. Extract every table into a Pandas DataFrame
        for table in table_names:
            print(f"Loading table: {table}...")

            query = text(f'SELECT * FROM "{table}"')

            all_tables[table] = pd.read_sql(
                query,
                connection
            )

    print("\nAll tables loaded successfully!")

    # 5. Return the extracted DataFrames
    return all_tables


# Run extraction directly when this file is executed
if __name__ == "__main__":

    all_tables = extract_tables()

    print("\nTables found:", list(all_tables.keys()))
    print("Number of tables:", len(all_tables))
