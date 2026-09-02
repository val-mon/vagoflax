import pandas as pd
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

from encoding import encode_data
from preprocessing import preprocess
from regression_model.scripts.train import train as lin_reg_train
from gradient_boosting_model.scripts.train import train as gb_train
from NN_model.scripts.train import train as nn_train
from export import save_preprocessing_metadata, save_model

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR.joinpath("data", "swiss_job_offers.csv")

RESULTS_PATH = BASE_DIR.joinpath("results")
RESULTS_PATH.mkdir(parents=True, exist_ok=True)

VISUALIZATION_DIR = BASE_DIR.joinpath("visualization")
VISUALIZATION_DIR.mkdir(parents=True, exist_ok=True)

COMPARISON_DIR = BASE_DIR.joinpath("comparison")
COMPARISON_DIR.mkdir(parents=True, exist_ok=True)

EXPORT_DIR = BASE_DIR.joinpath("export")
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

TRAIN_RATIO = 0.7
VALIDATION_RATIO = 0.15
TEST_RATIO = 0.15
EPOCHS = 500
PATIENCE = 50
MIN_DELTA = 1e-4

RANDOM_SEED = 42


def main():
    # load dataset
    df = pd.read_csv(DATA_PATH)

    # preprocess dataset (e.g., handle missing values, encode categorical variables, etc.)
    df, Y = preprocess(df)

    workload = df["WorkloadPercent"].copy()

    # encode dataset
    df, one_hot_categories, multi_hot_categories = encode_data(df)

    # split dataset into train, validation, and test sets
    X_train, X_temp, Y_train, Y_temp, workload_train, workload_temp = train_test_split(
        df,
        Y,
        workload,
        test_size=(1 - TRAIN_RATIO),
        random_state=RANDOM_SEED,
    )
    validation_size = VALIDATION_RATIO / (VALIDATION_RATIO + TEST_RATIO)
    X_validation, X_test, Y_validation, Y_test, workload_validation, workload_test = (
        train_test_split(
            X_temp,
            Y_temp,
            workload_temp,
            test_size=(1 - validation_size),
            random_state=RANDOM_SEED,
        )
    )

    # shapes
    print(f"X_train shape: {X_train.shape}")
    print(f"X_validation shape: {X_validation.shape}")
    print(f"X_test shape: {X_test.shape}")
    print(f"Y_train shape: {Y_train.shape}")
    print(f"Y_validation shape: {Y_validation.shape}")
    print(f"Y_test shape: {Y_test.shape}")

    X_train, X_validation, X_test, Y_train, Y_validation, Y_test, scaler_X, scaler_y = (
        normalize_salary(X_train, X_validation, X_test, Y_train, Y_validation, Y_test)
    )

    # train models
    lin_reg_train(
        X_train,
        X_validation,
        X_test,
        Y_train,
        Y_validation,
        Y_test,
        base_dir=BASE_DIR,
        scaler_y=scaler_y,
    )

    gb_train(
        X_train,
        X_validation,
        X_test,
        Y_train,
        Y_validation,
        Y_test,
        base_dir=BASE_DIR,
        scaler_y=scaler_y,
        random_state=RANDOM_SEED,
    )

    nn_model = nn_train(
        X_train,
        X_validation,
        X_test,
        Y_train,
        Y_validation,
        Y_test,
        workload_train,
        workload_validation,
        workload_test,
        base_dir=BASE_DIR,
        scaler_y=scaler_y,
        random_state=RANDOM_SEED,
        epochs=EPOCHS,
        patience=PATIENCE,
        min_delta=MIN_DELTA,
    )

    compare_results()

    columns_to_scale = [
        "MinYearsExperience",
        "Holidays",
        "Contract",
    ]

    binary_columns = [
        "IsPermanent",
    ]

    save_preprocessing_metadata(
        X_train=X_train,
        scaler_X=scaler_X,
        scaler_y=scaler_y,
        columns_to_scale=columns_to_scale,
        one_hot_categories=one_hot_categories,
        multi_hot_categories=multi_hot_categories,
        binary_columns=binary_columns,
        output_dir=EXPORT_DIR,
    )

    X_train_full = pd.concat([X_train, X_validation], axis=0)

    save_model(
        model=nn_model,
        X_train_full=X_train_full,
        output_dir=EXPORT_DIR,
    )


def compare_results():
    import re
    import numpy as np
    import matplotlib.pyplot as plt

    lin_reg_results_path = BASE_DIR.joinpath(
        "regression_model", "results", "linear_regression_results.txt"
    )
    gb_results_path = BASE_DIR.joinpath(
        "gradient_boosting_model", "results", "gradient_boosting_results.txt"
    )
    nn_results_path = BASE_DIR.joinpath(
        "NN_model", "results", "neural_network_results.txt"
    )

    def load_results(path):
        with open(path, "r") as f:
            content = f.read()

        results = {}

        for metric in ["MAE", "RMSE", "R²"]:
            match = re.search(
                rf"{re.escape(metric)}\s*-\s*Train:\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)(?:\s*CHF)?\s*,\s*Test:\s*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)",
                content,
            )

            if match is None:
                raise ValueError(f"Could not find {metric} results in {path}")

            results[metric] = {
                "Train": float(match.group(1)),
                "Test": float(match.group(2)),
            }

        return results

    lin_reg_results = load_results(lin_reg_results_path)
    gb_results = load_results(gb_results_path)
    nn_results = load_results(nn_results_path)

    models = ["Linear Regression", "Gradient Boosting", "Neural Network"]
    results = [lin_reg_results, gb_results, nn_results]
    metrics = ["MAE", "RMSE", "R²"]

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    x = np.arange(len(models))
    width = 0.35

    for ax, metric in zip(axes, metrics):
        train_values = [result[metric]["Train"] for result in results]
        test_values = [result[metric]["Test"] for result in results]

        train_bars = ax.bar(x - width / 2, train_values, width, label="Train")
        test_bars = ax.bar(x + width / 2, test_values, width, label="Test")

        ax.set_title(metric)
        ax.set_xticks(x)
        ax.set_xticklabels(models, rotation=20, ha="right")

        if metric in ["MAE", "RMSE"]:
            ax.set_ylabel("CHF")
        else:
            ax.set_ylabel("Score")
            ax.set_ylim(min(min(train_values), min(test_values), 0), 1.05)

        ax.bar_label(train_bars, fmt="%.2f", padding=3)
        ax.bar_label(test_bars, fmt="%.2f", padding=3)
        ax.legend()
        ax.grid(axis="y", alpha=0.3)

    fig.suptitle("Model Performance Comparison", fontsize=16)

    plt.tight_layout()

    plt.savefig(
        COMPARISON_DIR.joinpath("model_comparison.png"), dpi=300, bbox_inches="tight"
    )
    plt.close()


def normalize_salary(X_train, X_validation, X_test, Y_train, Y_validation, Y_test):
    # Normalize the salary column using z-score normalization
    # It must be done after the train-test split to avoid data leakage
    # Everything should be normalized based on the training set
    scaler_y = StandardScaler()
    Y_train = scaler_y.fit_transform(Y_train.values.reshape(-1, 1)).flatten()
    Y_validation = scaler_y.transform(Y_validation.values.reshape(-1, 1)).flatten()
    Y_test = scaler_y.transform(Y_test.values.reshape(-1, 1)).flatten()

    columns_to_scale = [
        "MinYearsExperience",
        "Holidays",
        "Contract",
    ]

    scaler_X = StandardScaler()

    X_train = X_train.copy()
    X_validation = X_validation.copy()
    X_test = X_test.copy()
    X_train[columns_to_scale] = scaler_X.fit_transform(X_train[columns_to_scale])
    X_validation[columns_to_scale] = scaler_X.transform(X_validation[columns_to_scale])
    X_test[columns_to_scale] = scaler_X.transform(X_test[columns_to_scale])

    return (
        X_train,
        X_validation,
        X_test,
        Y_train,
        Y_validation,
        Y_test,
        scaler_X,
        scaler_y,
    )


if __name__ == "__main__":
    main()
