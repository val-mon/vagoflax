import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
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
    random_state,
):

    # Search for best hyperparameters using the validation set
    param_grid = _generate_param_grid(
        n_estimators_values=[100, 200, 300, 500],
        learning_rate_values=[0.1, 0.2, 0.3, 0.4],
        max_depth_values=[1, 2, 3],
    )

    best_params = None
    best_rmse = np.inf

    for params in param_grid:
        model = GradientBoostingRegressor(
            n_estimators=params["n_estimators"],
            learning_rate=params["learning_rate"],
            max_depth=params["max_depth"],
            random_state=random_state,
        )

        model.fit(X_train, Y_train)

        Y_pred_validation = model.predict(X_validation)

        # Convert validation values back to CHF
        Y_pred_validation_chf = scaler_y.inverse_transform(
            Y_pred_validation.reshape(-1, 1)
        ).flatten()

        Y_validation_chf = scaler_y.inverse_transform(
            Y_validation.reshape(-1, 1)
        ).flatten()

        rmse_validation = root_mean_squared_error(
            Y_validation_chf, Y_pred_validation_chf
        )

        print(f"Params: {params}, Validation RMSE: {rmse_validation:.4f}")

        if rmse_validation < best_rmse:
            best_rmse = rmse_validation
            best_params = params

    # combine train and validation after hyperparameter selection
    X_train_full = pd.concat([X_train, X_validation], axis=0)
    Y_train_full = np.concatenate([Y_train, Y_validation], axis=0)

    # Gradient boosting regression model
    model = GradientBoostingRegressor(
        n_estimators=best_params["n_estimators"],
        learning_rate=best_params["learning_rate"],
        max_depth=best_params["max_depth"],
        random_state=random_state,
    )

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

    gb_model_dir = base_dir.joinpath("gradient_boosting_model")
    results_dir = gb_model_dir.joinpath("results")
    visualization_dir = gb_model_dir.joinpath("visualization")

    if not results_dir.exists():
        results_dir.mkdir(parents=True, exist_ok=True)
    if not visualization_dir.exists():
        visualization_dir.mkdir(parents=True, exist_ok=True)

    results_path = results_dir.joinpath("gradient_boosting_results.txt")
    visualization_path = visualization_dir.joinpath("gradient_boosting_predictions.png")

    # Save results
    with open(results_path, "w") as f:
        f.write("Gradient Boosting Regression Parameters:\n")
        f.write(f"n_estimators: {model.n_estimators}\n")
        f.write(f"learning_rate: {model.learning_rate}\n")
        f.write(f"max_depth: {model.max_depth}\n")
        f.write(f"Validation RMSE during hyperparameter search: {best_rmse}\n")
        f.write("Dataset split:\n")
        f.write(f"Training set size: {X_train_full.shape[0]}\n")
        f.write(f"Test set size: {X_test.shape[0]}\n")
        f.write(
            f"Train-Test split percentage: "
            f"{X_train_full.shape[0] / (X_train_full.shape[0] + X_test.shape[0]) * 100:.2f}% - "
            f"{X_test.shape[0] / (X_train_full.shape[0] + X_test.shape[0]) * 100:.2f}%\n\n"
        )
        f.write("Gradient Boosting Regression Results: \n")
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



from itertools import product


def _generate_param_grid(n_estimators_values, learning_rate_values, max_depth_values):
    param_grid = []

    for n_estimators, learning_rate, max_depth in product(
        n_estimators_values, learning_rate_values, max_depth_values
    ):
        param_grid.append(
            {
                "n_estimators": n_estimators,
                "learning_rate": learning_rate,
                "max_depth": max_depth,
            }
        )

    return param_grid
