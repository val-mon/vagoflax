import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path

DATASET_PATH = Path(__file__).parent.parent / "data" / "swiss_job_offers.csv"
TARGET_COLUMN = "SalaryCHF"


def main():
    # Load the dataset
    df = pd.read_csv(DATASET_PATH)

    # Separate the target from the input features
    X = df.drop(columns=[TARGET_COLUMN]).copy()
    y = pd.to_numeric(df[TARGET_COLUMN], errors="coerce")

    # Automatically detect categorical and numerical columns
    categorical_columns = X.select_dtypes(
        include=["object", "category", "bool"]
    ).columns.tolist()

    numeric_columns = X.select_dtypes(include="number").columns.tolist()

    # Convert categorical variables into numerical variables using one-hot encoding
    X_encoded = pd.get_dummies(
        X, columns=categorical_columns, prefix_sep="__", drop_first=False, dtype=float
    )

    # Add the target column to calculate correlations
    data = pd.concat([X_encoded, y.rename(TARGET_COLUMN)], axis=1)

    # Calculate the absolute correlation of each encoded feature with SalaryCHF
    correlations = data.corr(numeric_only=True)[TARGET_COLUMN].drop(TARGET_COLUMN).abs()

    # Group encoded columns to get one influence score per original feature
    influence = {}

    # Process numerical features
    for column in numeric_columns:
        if column in correlations.index:
            influence[column] = correlations[column]

    # Process categorical features
    for column in categorical_columns:
        dummy_columns = [
            encoded_column
            for encoded_column in correlations.index
            if encoded_column.startswith(f"{column}__")
        ]

        if dummy_columns:
            # Keep the category with the strongest absolute correlation
            influence[column] = correlations[dummy_columns].max()

    # Sort features from most to least correlated with the target
    influence = (
        pd.Series(influence, name="Influence").dropna().sort_values(ascending=False)
    )

    # Display the ranking in the terminal
    print("\nFeatures most strongly related to SalaryCHF:\n")
    print(influence)

    # Create the correlation chart
    plt.figure(figsize=(10, max(6, len(influence) * 0.45)))

    influence.sort_values().plot(kind="barh")

    plt.title("Feature Influence on SalaryCHF")
    plt.xlabel("Absolute Correlation with SalaryCHF")
    plt.ylabel("Feature")

    plt.tight_layout()

    output_path = (
        Path(__file__).parent / "correlation_plot.png"
    )

    # Create the output directory if it does not exist
    output_path.parent.mkdir(parents=True, exist_ok=True)

    plt.savefig(output_path, dpi=150)
    plt.show()


if __name__ == "__main__":
    main()
