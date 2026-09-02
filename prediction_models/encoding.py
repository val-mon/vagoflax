"""
Encoding module for the prediction models.
Expect preprocessed data as input and return encoded data for model training and evaluation.
"""

import pandas as pd
from sklearn.preprocessing import OneHotEncoder, MultiLabelBinarizer

# Numerical columns
numerical_columns = [
    "MinYearsExperience",
    "Holidays",
    "Contract",
    "IsPermanent",
]

# One-hot columns
nominal_columns = ["Diploma", "Role", "Industry", "Canton", "CompanySize"]


# Multi-label / multi-hot columns
multi_label_columns = ["Perks", "Languages"]


def encode_data(df_preprocessed):

    import pandas as pd
    from sklearn.preprocessing import OrdinalEncoder, OneHotEncoder, MultiLabelBinarizer

    df = df_preprocessed.copy()

    print(df["CompanySize"].unique())


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
    multi_hot_categories = {}

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
        multi_hot_categories[column] = multi_label_encoder.classes_.tolist()
        multi_hot_dfs.append(encoded_df)

    # Combine
    df_encoded = pd.concat(
        [df[numerical_columns], one_hot_df, *multi_hot_dfs],
        axis=1,
    )

    one_hot_categories = {
        column: categories.tolist()
        for column, categories in zip(
            nominal_columns,
            one_hot_encoder.categories_,
        )
    }

    return df_encoded, one_hot_categories, multi_hot_categories




if __name__ == "__main__":
    from pathlib import Path
    from preprocessing import preprocess

    data_path = Path(__file__).resolve().parent / "data" / "swiss_job_offers.csv"
    df = pd.read_csv(data_path)

    df = preprocess(df)
    df, one_hot_categories, multi_hot_categories = encode_data(df)

    print(df.columns)
    print(df.head())

    # print perks columns
    perks_columns = [col for col in df.columns if col.startswith("Perks_")]
    perks_df = df[perks_columns]
    print(perks_df.head())
