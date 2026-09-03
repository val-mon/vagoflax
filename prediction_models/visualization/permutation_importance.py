import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from pathlib import Path

from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from sklearn.inspection import permutation_importance
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, MultiLabelBinarizer

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

    y = df[TARGET_COLUMN]
    X = df.drop(columns=[TARGET_COLUMN]).copy()

    encoded_parts = []
    feature_groups = {}

    # Encode multi-label columns
    for column in MULTILABEL_COLUMNS:
        mlb = MultiLabelBinarizer()

        encoded = mlb.fit_transform(X[column].apply(split_multilabel))
        columns = [f"{column}__{value}" for value in mlb.classes_]
        encoded_df = pd.DataFrame(encoded, columns=columns, index=X.index)

        encoded_parts.append(encoded_df)
        feature_groups[column] = columns

    X = X.drop(columns=MULTILABEL_COLUMNS)

    categorical_columns = X.select_dtypes(
        include=["object", "category", "bool"]
    ).columns.tolist()

    numeric_columns = X.select_dtypes(include="number").columns.tolist()

    # Fill missing numerical values
    for column in numeric_columns:
        X[column] = pd.to_numeric(X[column], errors="coerce")

        X[column] = X[column].fillna(X[column].median())

    # One-hot encode standard categorical columns
    if categorical_columns:
        encoder = OneHotEncoder(handle_unknown="ignore", sparse_output=False)

        categorical_data = X[categorical_columns].fillna("Missing")
        encoded = encoder.fit_transform(categorical_data)
        encoded_columns = encoder.get_feature_names_out(categorical_columns)
        categorical_df = pd.DataFrame(encoded, columns=encoded_columns, index=X.index)
        encoded_parts.append(categorical_df)

        for column in categorical_columns:
            feature_groups[column] = [
                encoded_column
                for encoded_column in encoded_columns
                if encoded_column.startswith(f"{column}_")
            ]

    # Add numerical columns
    numeric_df = X[numeric_columns].copy()
    encoded_parts.append(numeric_df)

    for column in numeric_columns:
        feature_groups[column] = [column]

    X_encoded = pd.concat(encoded_parts, axis=1)

    # Split dataset
    X_train, X_test, y_train, y_test = train_test_split(
        X_encoded, y, test_size=0.2, random_state=42
    )

    # Train model
    model = RandomForestRegressor(n_estimators=300, random_state=42, n_jobs=-1)

    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    print("\nModel performance:\n")
    print(f"MAE: {mean_absolute_error(y_test, predictions):,.2f} CHF")
    print(f"R²:  {r2_score(y_test, predictions):.3f}")

    # Calculate permutation importance
    result = permutation_importance(
        model,
        X_test,
        y_test,
        scoring="neg_mean_absolute_error",
        n_repeats=20,
        random_state=42,
        n_jobs=-1,
    )

    encoded_importance = pd.Series(result.importances_mean, index=X_encoded.columns)

    # Aggregate encoded columns into original features
    feature_importance = {}

    for feature, columns in feature_groups.items():
        feature_importance[feature] = encoded_importance[columns].sum()

    feature_importance = pd.Series(
        feature_importance, name="Permutation Importance"
    ).sort_values(ascending=False)

    print("\nPermutation Importance:\n")
    print(feature_importance.to_string())

    # Plot results
    plt.figure(figsize=(10, max(6, len(feature_importance) * 0.45)))

    feature_importance.sort_values().plot(kind="barh")

    plt.title("Permutation Importance for SalaryCHF")
    plt.xlabel("Increase in MAE when feature is shuffled")
    plt.ylabel("Feature")

    plt.tight_layout()

    output_path = Path(__file__).parent / "permutation_importance_plot.png"

    output_path.parent.mkdir(parents=True, exist_ok=True)

    plt.savefig(output_path, dpi=150, bbox_inches="tight")
    plt.show()


if __name__ == "__main__":
    main()
