
from ml.src.data.transform import transform_tables


def run_pipeline():

    print("\n========== FRAUD GUARD LIVE PIPELINE ==========\n")

    # 1. Extract, inspect, clean, and validate
    print("STEP 1: TRANSFORMING DATA")

    results = transform_tables()

    raw_tables = results["raw_tables"]
    cleaned_tables = results["cleaned_tables"]
    validation_issues = results["validation_issues"]

    # 2. Pipeline summary
    print("\n========== PIPELINE SUMMARY ==========")

    print(f"Tables extracted: {len(raw_tables)}")
    print(f"Tables cleaned: {len(cleaned_tables)}")
    print(f"Validation issues: {len(validation_issues)}")

    if validation_issues:
        print("\nVALIDATION ISSUES:")

        for issue in validation_issues:
            print(issue)
    else:
        print("\nNo validation issues found.")

    print("\n========== PIPELINE FINISHED ==========")

    return results


if __name__ == "__main__":
    pipeline_results = run_pipeline()
