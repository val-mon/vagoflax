import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path

from sklearn.feature_selection import mutual_info_regression
from sklearn.preprocessing import OrdinalEncoder, MultiLabelBinarizer

DATASET_PATH = Path(__file__).parent.parent / "data" / "swiss_job_offers.csv"
TARGET_COLUMN = "SalaryCHF"

MULTILABEL_COLUMNS = [
    "Languages",
    "Perks",
]


def split_multilabel(value):
    if pd.isna(value):
        return []

    return [item.strip() for item in str(value).split(",") if item.strip()]


def main():
    # Load dataset
    df = pd.read_csv(DATASET_PATH)
    df[TARGET_COLUMN] = pd.to_numeric(df[TARGET_COLUMN], errors="coerce")
    df = df.dropna(subset=[TARGET_COLUMN]).copy()

    X = df.drop(columns=[TARGET_COLUMN]).copy()
    y = df[TARGET_COLUMN]

    X_encoded = pd.DataFrame(index=X.index)
    feature_groups = {}
    discrete_features = []

    # Encode multi-label columns
    for column in MULTILABEL_COLUMNS:
        values = X[column].apply(split_multilabel)

        mlb = MultiLabelBinarizer()

        encoded = mlb.fit_transform(values)
        encoded_columns = [f"{column}__{category}" for category in mlb.classes_]
        encoded_df = pd.DataFrame(encoded, columns=encoded_columns, index=X.index)
        X_encoded = pd.concat([X_encoded, encoded_df], axis=1)

        feature_groups[column] = encoded_columns
        discrete_features.extend([True] * len(encoded_columns))

    remaining_X = X.drop(columns=MULTILABEL_COLUMNS).copy()

    categorical_columns = remaining_X.select_dtypes(
        include=["object", "category", "bool"]
    ).columns.tolist()

    numeric_columns = remaining_X.select_dtypes(include="number").columns.tolist()

    # Keep numerical columns as continuous features
    for column in numeric_columns:
        values = pd.to_numeric(remaining_X[column], errors="coerce")

        values = values.fillna(values.median())

        X_encoded[column] = values
        feature_groups[column] = [column]
        discrete_features.append(False)

    # Encode standard categorical columns
    if categorical_columns:
        categorical_data = remaining_X[categorical_columns].fillna("Missing")

        encoder = OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1)

        encoded_categories = encoder.fit_transform(categorical_data)

        for i, column in enumerate(categorical_columns):
            X_encoded[column] = encoded_categories[:, i]
            feature_groups[column] = [column]
            discrete_features.append(True)

    # Calculate Mutual Information
    mi_scores = mutual_info_regression(
        X_encoded, y, discrete_features=discrete_features, random_state=42
    )

    encoded_importance = pd.Series(
        mi_scores, index=X_encoded.columns, name="Mutual Information"
    )

    feature_importance = {}

    for original_feature, encoded_columns in feature_groups.items():
        scores = encoded_importance[encoded_columns]

        if original_feature in MULTILABEL_COLUMNS:
            feature_importance[original_feature] = scores.max()
        else:
            feature_importance[original_feature] = scores.iloc[0]

    feature_importance = pd.Series(
        feature_importance, name="Mutual Information"
    ).sort_values(ascending=False)

    print("\nMutual Information with SalaryCHF:\n")
    print(feature_importance.to_string())

    # Show details for multi-label features
    for column in MULTILABEL_COLUMNS:
        print(f"\nDetails for {column}:")

        detailed_scores = encoded_importance[feature_groups[column]].sort_values(
            ascending=False
        )

        detailed_scores.index = [
            name.replace(f"{column}__", "") for name in detailed_scores.index
        ]

        print(detailed_scores.to_string())

    # Plot results
    plt.figure(figsize=(10, max(6, len(feature_importance) * 0.45)))

    feature_importance.sort_values().plot(kind="barh")

    plt.title("Mutual Information with SalaryCHF")
    plt.xlabel("Mutual Information Score")
    plt.ylabel("Feature")

    plt.tight_layout()

    output_path = (
        Path(__file__).parent / "mutual_information_plot.png"
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)

    plt.savefig(output_path, dpi=150, bbox_inches="tight")
    plt.show()


if __name__ == "__main__":
    main()
