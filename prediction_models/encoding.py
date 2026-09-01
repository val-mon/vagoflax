"""
Encoding module for the prediction models.
Expect preprocessed data as input and return encoded data for model training and evaluation.
"""

import pandas as pd
from sklearn.preprocessing import OneHotEncoder, MultiLabelBinarizer

# Target
target = "SalaryCHF"

# Numerical columns
numerical_columns = [
    "MinYearsExperience",
    "Holidays",
    "WorkloadPercent",
    "Contract",
    "IsPermanent",
]

# Ordinal columns
ordinal_columns = ["Diploma", "Role", "CompanySize"]

# Ordinal lists
diploma_order = ["Unknown", "Apprenticeship", "Bachelor", "Master", "PhD"]

role_order = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager"]

company_size_order = ["Startup", "Small", "Medium", "Large"]

ordinal_categories = [diploma_order, role_order, company_size_order]

# One-hot columns
nominal_columns = ["Industry", "Canton"]

# Multi-label / multi-hot columns
multi_label_columns = ["Perks", "Languages"]


def encode_data(df_preprocessed):

    import pandas as pd
    from sklearn.preprocessing import OrdinalEncoder, OneHotEncoder, MultiLabelBinarizer

    df = df_preprocessed.copy()

    ordinal_encoder = OrdinalEncoder(
        categories=[diploma_order, role_order, company_size_order],
        handle_unknown="use_encoded_value",
        unknown_value=-1,
    )

    ordinal_encoded = ordinal_encoder.fit_transform(df[ordinal_columns])

    ordinal_df = pd.DataFrame(ordinal_encoded, columns=ordinal_columns, index=df.index)

    # One-hot encoding

    one_hot_encoder = OneHotEncoder(handle_unknown="ignore", sparse_output=False)

    one_hot_encoded = one_hot_encoder.fit_transform(df[nominal_columns])

    one_hot_df = pd.DataFrame(
        one_hot_encoded,
        columns=one_hot_encoder.get_feature_names_out(nominal_columns),
        index=df.index,
    )

    # Multi-hot encoding

    multi_hot_dfs = []

    for column in multi_label_columns:

        # "English, German" -> ["English", "German"]
        values = (
            df[column]
            .fillna("Unknown")
            .str.split(",")
            .apply(lambda x: [item.strip() for item in x])
        )

        multi_label_encoder = MultiLabelBinarizer()

        encoded = multi_label_encoder.fit_transform(values)

        encoded_df = pd.DataFrame(
            encoded,
            columns=[
                f"{column}_{category}" for category in multi_label_encoder.classes_
            ],
            index=df.index,
        )

        multi_hot_dfs.append(encoded_df)

    # Combine

    df_encoded = pd.concat(
        [df[numerical_columns], ordinal_df, one_hot_df, *multi_hot_dfs, df[[target]]],
        axis=1,
    )

    return df_encoded


if __name__ == "__main__":
    from pathlib import Path
    from preprocessing import preprocess

    data_path = Path(__file__).resolve().parent / "data" / "swiss_job_offers.csv"
    df = pd.read_csv(data_path)

    df = preprocess(df)
    df = encode_data(df)

    print(df.columns)
    print(df.head())

    # print perks columns
    perks_columns = [col for col in df.columns if col.startswith("Perks_")]
    perks_df = df[perks_columns]
    print(perks_df.head())
