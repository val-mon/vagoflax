def preprocess(df):
    # Drop
    df = drop_irrelevant_columns(df)
    df = clean_min_years_of_experience(df)
    df = clean_company_size(df)
    df = replace_missing_values(df)
    df = clean_contract_length(df)

    return df


def drop_irrelevant_columns(df):
    # Drop columns that are not relevant for the prediction task
    columns_to_drop = [
        "MaternityLeaveWeeks",
        "PaternityLeaveWeeks",
    ]  # Replace with actual column names
    df = df.drop(columns=columns_to_drop)
    return df


def clean_min_years_of_experience(df):
    # remove the max. 4 to 7 -> 4

    df["MinYearsExperience"] = df["MinYearsExperience"].apply(
        lambda x: (
            int(x.split(" ")[0])
            if isinstance(x, str)
            else x if isinstance(x, int) else 0
        )
    )

    return df


def clean_company_size(df):
    # remove the range : Small (50 - 200) -> Small

    df["CompanySize"] = df["CompanySize"].apply(
        lambda x: (
            x.split(" ")[0] if isinstance(x, str) else x if isinstance(x, int) else 0
        )
    )

    return df


def replace_missing_values(df):
    # replace missing values with placeholder token ("Unknown")
    df = df.fillna("Unknown")
    return df


def clean_contract_length(df):
    # create a new column "IsPermanent" to indicate whether the contract is permanent or not
    df["IsPermanent"] = (df["Contract"] == "Permanent").astype(int)

    # permanent or years to months : Permanent -> 0, 6 months -> 6, 1 year -> 12, 2 years -> 24, ...
    df["Contract"] = df["Contract"].apply(
        lambda x: (
            0
            if x == "Permanent"
            else (
                int(x.split(" ")[0]) * 12
                if "year" in x
                else int(x.split(" ")[0]) if "month" in x else 0
            )
        )
    )

    return df


if __name__ == "__main__":
    from pathlib import Path
    import pandas as pd

    data_path = Path(__file__).resolve().parent / "data" / "swiss_job_offers.csv"
    df = pd.read_csv(data_path)
    df = preprocess(df)
    print(df)
