import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, root_mean_squared_error, r2_score
import matplotlib.pyplot as plt


def train(
    X_train,
    X_validation,
    X_test,
    Y_train,
    Y_validation,
    Y_test,
    base_dir,
    scaler_y,
):
    # combine train and validation, since linear regression doesn't have epochs or early stopping
    X_train_full = pd.concat([X_train, X_validation], axis=0)
    Y_train_full = np.concatenate([Y_train, Y_validation], axis=0)

    # linear regression model
    model = LinearRegression()
    model.fit(X_train_full, Y_train_full)

    # Make predictions
    Y_pred_train = model.predict(X_train_full)
    Y_pred_test = model.predict(X_test)

    # Convert predictions back to CHF
    Y_pred_train = scaler_y.inverse_transform(Y_pred_train.reshape(-1, 1)).flatten()
    Y_pred_test = scaler_y.inverse_transform(Y_pred_test.reshape(-1, 1)).flatten()

    # Convert actual values back to CHF
    Y_train_full = scaler_y.inverse_transform(Y_train_full.reshape(-1, 1)).flatten()
    Y_test = scaler_y.inverse_transform(Y_test.reshape(-1, 1)).flatten()

    # Calculate metrics
    mae_train = mean_absolute_error(Y_train_full, Y_pred_train)
    mae_test = mean_absolute_error(Y_test, Y_pred_test)

    rmse_train = root_mean_squared_error(Y_train_full, Y_pred_train)
    rmse_test = root_mean_squared_error(Y_test, Y_pred_test)

    r2_train = r2_score(Y_train_full, Y_pred_train)
    r2_test = r2_score(Y_test, Y_pred_test)

    reg_model_dir = base_dir.joinpath("regression_model")
    results_dir = reg_model_dir.joinpath("results")
    visualization_dir = reg_model_dir.joinpath("visualization")

    if not results_dir.exists():
        results_dir.mkdir(parents=True, exist_ok=True)
    if not visualization_dir.exists():
        visualization_dir.mkdir(parents=True, exist_ok=True)

    results_path = results_dir.joinpath("linear_regression_results.txt")
    visualization_path = visualization_dir.joinpath("linear_regression_predictions.png")

    # Save results
    with open(results_path, "w") as f:
        f.write("Linear Regression Parameters:\n")
        f.write(f"Coefficients: {model.coef_}\n")
        f.write(f"Intercept: {model.intercept_}\n\n")
        f.write("Dataset split:\n")
        f.write(f"Training set size: {X_train_full.shape[0]}\n")
        f.write(f"Test set size: {X_test.shape[0]}\n")
        f.write(f"Train-Test split percentage: {X_train_full.shape[0] / (X_train_full.shape[0] + X_test.shape[0]) * 100:.2f}% - {X_test.shape[0] / (X_train_full.shape[0] + X_test.shape[0]) * 100:.2f}%\n\n")
        f.write("Linear Regression Results: \n")
        f.write(f"MAE - Train: {mae_train}, Test: {mae_test}\n")
        f.write(f"RMSE - Train: {rmse_train}, Test: {rmse_test}\n")
        f.write(f"R² - Train: {r2_train}, Test: {r2_test}\n")

    # save visualization of predictions vs actual values
    plt.figure(figsize=(10, 6))
    plt.scatter(Y_test, Y_pred_test, alpha=0.5)
    plt.plot([Y_test.min(), Y_test.max()], [Y_test.min(), Y_test.max()], "k--", lw=2)
    plt.xlabel("Actual")
    plt.ylabel("Predicted")
    plt.title("Actual vs Predicted")
    plt.savefig(visualization_path)
    plt.close()

