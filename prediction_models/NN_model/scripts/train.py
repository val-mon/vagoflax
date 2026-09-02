import json

import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import litert_torch
from sklearn.metrics import (
    mean_absolute_error,
    root_mean_squared_error,
    r2_score,
)
import matplotlib.pyplot as plt


class SalaryModel(nn.Module):
    def __init__(self, input_size):
        super().__init__()

        self.network = nn.Sequential(
            nn.Linear(input_size, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1),
        )

    def forward(self, x):
        return self.network(x)


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
    epochs,
    patience,
    min_delta,
):
    # Reproducibility
    np.random.seed(random_state)
    torch.manual_seed(random_state)

    # Convert datasets to tensors
    X_train_tensor = torch.tensor(
        X_train.values,
        dtype=torch.float32,
    )

    X_validation_tensor = torch.tensor(
        X_validation.values,
        dtype=torch.float32,
    )

    X_test_tensor = torch.tensor(
        X_test.values,
        dtype=torch.float32,
    )

    Y_train_tensor = torch.tensor(
        Y_train,
        dtype=torch.float32,
    ).reshape(-1, 1)

    Y_validation_tensor = torch.tensor(
        Y_validation,
        dtype=torch.float32,
    ).reshape(-1, 1)

    # Train the model with 70 % of the data and 15 % for validation
    model = SalaryModel(X_train.shape[1])
    criterion = nn.MSELoss()

    optimizer = torch.optim.Adam(
        model.parameters(),
        lr=0.001,
        weight_decay=1e-3,
    )

    best_validation_loss = np.inf
    best_epoch = 0
    patience_counter = 0

    # For plots
    train_rmse_history = []
    validation_rmse_history = []

    for epoch in range(epochs):
        model.train()
        optimizer.zero_grad()

        Y_pred_train = model(X_train_tensor)
        train_loss = criterion(
            Y_pred_train,
            Y_train_tensor,
        )

        train_loss.backward()
        optimizer.step()

        # validation
        model.eval()

        with torch.no_grad():
            # Recompute train predictions after optimizer step
            Y_pred_train_eval = model(X_train_tensor)
            Y_pred_validation = model(X_validation_tensor)

            validation_loss = criterion(
                Y_pred_validation,
                Y_validation_tensor,
            ).item()

            # Convert train predictions to CHF
            Y_pred_train_chf = scaler_y.inverse_transform(
                Y_pred_train_eval.numpy()
            ).flatten()

            Y_train_chf = scaler_y.inverse_transform(Y_train_tensor.numpy()).flatten()
            train_rmse_chf = root_mean_squared_error(
                Y_train_chf,
                Y_pred_train_chf,
            )

            # Convert validation predictions to CHF
            Y_pred_validation_chf = scaler_y.inverse_transform(
                Y_pred_validation.numpy()
            ).flatten()

            Y_validation_chf = scaler_y.inverse_transform(
                Y_validation_tensor.numpy()
            ).flatten()

            validation_rmse_chf = root_mean_squared_error(
                Y_validation_chf,
                Y_pred_validation_chf,
            )

        train_rmse_history.append(train_rmse_chf)
        validation_rmse_history.append(validation_rmse_chf)

        # Early stopping
        if validation_loss < best_validation_loss - min_delta:
            best_validation_loss = validation_loss
            best_epoch = epoch + 1
            patience_counter = 0
        else:
            patience_counter += 1

        # Print every 10 epochs
        if (epoch + 1) % 10 == 0 or epoch == 0 or patience_counter >= patience:
            print(
                f"Epoch {epoch + 1}/{epochs}, "
                f"Train RMSE: {train_rmse_chf:.2f} CHF, "
                f"Validation RMSE: {validation_rmse_chf:.2f} CHF, "
                f"Best Epoch: {best_epoch}"
            )

        if patience_counter >= patience:
            print(f"Early stopping at epoch {epoch + 1}. " f"Best epoch: {best_epoch}")
            break

    # Train the final model on the combined training and validation set using the best epoch
    X_train_full = pd.concat(
        [X_train, X_validation],
        axis=0,
    )

    Y_train_full = np.concatenate(
        [Y_train, Y_validation],
        axis=0,
    )

    X_train_full_tensor = torch.tensor(
        X_train_full.values,
        dtype=torch.float32,
    )

    Y_train_full_tensor = torch.tensor(
        Y_train_full,
        dtype=torch.float32,
    ).reshape(-1, 1)

    # Reset seed so final model initialization is reproducible
    torch.manual_seed(random_state)

    model = SalaryModel(X_train_full.shape[1])
    optimizer = torch.optim.Adam(
        model.parameters(),
        lr=0.001,
    )

    print(f"\nFinal training on train + validation " f"for {best_epoch} epochs...")

    for epoch in range(best_epoch):
        model.train()
        optimizer.zero_grad()

        Y_pred = model(X_train_full_tensor)

        loss = criterion(
            Y_pred,
            Y_train_full_tensor,
        )

        loss.backward()
        optimizer.step()

    # Final predictions on train and test sets
    model.eval()

    with torch.no_grad():
        Y_pred_train = model(X_train_full_tensor).numpy().flatten()

        Y_pred_test = model(X_test_tensor).numpy().flatten()

    # Convert predictions back to CHF
    Y_pred_train = scaler_y.inverse_transform(Y_pred_train.reshape(-1, 1)).flatten()
    Y_pred_test = scaler_y.inverse_transform(Y_pred_test.reshape(-1, 1)).flatten()

    # Convert actual values back to CHF
    Y_train_full_chf = scaler_y.inverse_transform(Y_train_full.reshape(-1, 1)).flatten()
    Y_test_chf = scaler_y.inverse_transform(Y_test.reshape(-1, 1)).flatten()

    # Metrics
    mae_train = mean_absolute_error(
        Y_train_full_chf,
        Y_pred_train,
    )

    mae_test = mean_absolute_error(
        Y_test_chf,
        Y_pred_test,
    )

    rmse_train = root_mean_squared_error(
        Y_train_full_chf,
        Y_pred_train,
    )

    rmse_test = root_mean_squared_error(
        Y_test_chf,
        Y_pred_test,
    )

    r2_train = r2_score(
        Y_train_full_chf,
        Y_pred_train,
    )

    r2_test = r2_score(
        Y_test_chf,
        Y_pred_test,
    )

    # Save directories
    nn_model_dir = base_dir.joinpath("NN_model")
    results_dir = nn_model_dir.joinpath("results")
    visualization_dir = nn_model_dir.joinpath("visualization")

    results_dir.mkdir(parents=True, exist_ok=True)
    visualization_dir.mkdir(parents=True, exist_ok=True)
    results_path = results_dir.joinpath("neural_network_results.txt")

    predictions_visualization_path = visualization_dir.joinpath(
        "neural_network_predictions.png"
    )

    training_visualization_path = visualization_dir.joinpath(
        "neural_network_training.png"
    )

    # Save results
    total_size = X_train_full.shape[0] + X_test.shape[0]
    train_percentage = X_train_full.shape[0] / total_size * 100
    test_percentage = X_test.shape[0] / total_size * 100

    with open(results_path, "w") as f:
        f.write("Neural Network Parameters:\n")
        f.write("Hidden layers: 64 - 32\n")
        f.write("Activation: ReLU\n")
        f.write("Optimizer: Adam\n")
        f.write("Learning rate: 0.001\n")
        f.write(f"Maximum epochs: {epochs}\n")
        f.write(f"Patience: {patience}\n")
        f.write(f"Best epoch: {best_epoch}\n\n")
        f.write("Dataset split:\n")
        f.write(f"Training set size: " f"{X_train_full.shape[0]}\n")
        f.write(f"Test set size: " f"{X_test.shape[0]}\n")
        f.write(
            f"Train-Test split percentage: "
            f"{train_percentage:.2f}% - "
            f"{test_percentage:.2f}%\n\n"
        )
        f.write("Neural Network Results:\n")
        f.write(f"MAE - Train: {mae_train:.2f} CHF, " f"Test: {mae_test:.2f} CHF\n")
        f.write(f"RMSE - Train: {rmse_train:.2f} CHF, " f"Test: {rmse_test:.2f} CHF\n")
        f.write(f"R² - Train: {r2_train:.6f}, " f"Test: {r2_test:.6f}\n")

    # save predictions vs actual values plot
    plt.figure(figsize=(10, 6))
    plt.scatter(
        Y_test_chf,
        Y_pred_test,
        alpha=0.5,
    )
    plt.plot(
        [
            Y_test_chf.min(),
            Y_test_chf.max(),
        ],
        [
            Y_test_chf.min(),
            Y_test_chf.max(),
        ],
        "k--",
        lw=2,
    )
    plt.xlabel("Actual Salary (CHF)")
    plt.ylabel("Predicted Salary (CHF)")
    plt.title("Neural Network - Actual vs Predicted")
    plt.tight_layout()
    plt.savefig(predictions_visualization_path)
    plt.close()

    # save training history plot
    plt.figure(figsize=(10, 6))
    epoch_numbers = range(
        1,
        len(train_rmse_history) + 1,
    )
    plt.plot(
        epoch_numbers,
        train_rmse_history,
        label="Train RMSE",
    )
    plt.plot(
        epoch_numbers,
        validation_rmse_history,
        label="Validation RMSE",
    )
    plt.axvline(
        x=best_epoch,
        linestyle="--",
        label=f"Best epoch: {best_epoch}",
    )
    plt.xlabel("Epoch")
    plt.ylabel("RMSE (CHF)")
    plt.title("Neural Network - Training History")
    plt.legend()
    plt.tight_layout()
    plt.savefig(training_visualization_path)
    plt.close()

    print("\nFinal results:")
    print(f"MAE  - Train: {mae_train:.2f} CHF, " f"Test: {mae_test:.2f} CHF")
    print(f"RMSE - Train: {rmse_train:.2f} CHF, " f"Test: {rmse_test:.2f} CHF")
    print(f"R²   - Train: {r2_train:.4f}, " f"Test: {r2_test:.4f}")

    return model
    

