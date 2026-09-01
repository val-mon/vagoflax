from copy import deepcopy
from pathlib import Path
import random

import numpy as np
import pandas as pd
import torch
from sklearn.model_selection import train_test_split
from torch import nn
from torch.utils.data import DataLoader, TensorDataset

from scripts.preprocessing import JobOfferPreprocessor
from scripts.model import SalaryModel


def set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)

    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)


def get_device() -> torch.device:
    if torch.cuda.is_available():
        return torch.device("cuda")

    if torch.backends.mps.is_available():
        return torch.device("mps")

    return torch.device("cpu")


def split_data(
    df: pd.DataFrame,
    train_ratio: float,
    validation_ratio: float,
    test_ratio: float,
    random_seed: int,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    remaining_ratio = validation_ratio + test_ratio

    train_df, remaining_df = train_test_split(
        df,
        test_size=remaining_ratio,
        random_state=random_seed,
        shuffle=True,
    )

    relative_test_ratio = test_ratio / remaining_ratio

    validation_df, test_df = train_test_split(
        remaining_df,
        test_size=relative_test_ratio,
        random_state=random_seed,
        shuffle=True,
    )

    return (
        train_df.reset_index(drop=True),
        validation_df.reset_index(drop=True),
        test_df.reset_index(drop=True),
    )


def prepare_data(
    train_df: pd.DataFrame,
    validation_df: pd.DataFrame,
    test_df: pd.DataFrame,
) -> tuple[
    JobOfferPreprocessor,
    TensorDataset,
    TensorDataset,
    TensorDataset,
    float,
    float,
]:
    preprocessor = JobOfferPreprocessor(
        scale_numeric=True,
    )

    preprocessor.fit(train_df)

    X_train, y_train = preprocessor.transform_to_tensors(train_df)
    X_validation, y_validation = preprocessor.transform_to_tensors(validation_df)
    X_test, y_test = preprocessor.transform_to_tensors(test_df)

    if y_train is None or y_validation is None or y_test is None:
        raise ValueError("SalaryCHF is missing from the dataset.")

    target_mean = y_train.mean().item()
    target_std = y_train.std(unbiased=False).item()

    if target_std == 0:
        target_std = 1.0

    y_train = (y_train - target_mean) / target_std
    y_validation = (y_validation - target_mean) / target_std
    y_test = (y_test - target_mean) / target_std

    train_dataset = TensorDataset(
        X_train,
        y_train,
    )

    validation_dataset = TensorDataset(
        X_validation,
        y_validation,
    )

    test_dataset = TensorDataset(
        X_test,
        y_test,
    )

    return (
        preprocessor,
        train_dataset,
        validation_dataset,
        test_dataset,
        target_mean,
        target_std,
    )


def create_loaders(
    train_dataset: TensorDataset,
    validation_dataset: TensorDataset,
    test_dataset: TensorDataset,
    batch_size: int,
    random_seed: int,
) -> tuple[DataLoader, DataLoader, DataLoader]:
    generator = torch.Generator()
    generator.manual_seed(random_seed)

    train_loader = DataLoader(
        train_dataset,
        batch_size=batch_size,
        shuffle=True,
        generator=generator,
    )

    validation_loader = DataLoader(
        validation_dataset,
        batch_size=batch_size,
        shuffle=False,
    )

    test_loader = DataLoader(
        test_dataset,
        batch_size=batch_size,
        shuffle=False,
    )

    return train_loader, validation_loader, test_loader


def compute_loss(
    model: nn.Module,
    data_loader: DataLoader,
    criterion: nn.Module,
    device: torch.device,
) -> float:
    model.eval()

    total_loss = 0.0
    total_samples = 0

    with torch.no_grad():
        for X, y in data_loader:
            X = X.to(device)
            y = y.to(device)

            predictions = model(X)
            loss = criterion(predictions, y)

            batch_size = X.size(0)

            total_loss += loss.item() * batch_size
            total_samples += batch_size

    return total_loss / total_samples


def evaluate(
    model: nn.Module,
    data_loader: DataLoader,
    device: torch.device,
    target_mean: float,
    target_std: float,
) -> dict[str, float]:
    model.eval()

    predictions = []
    targets = []

    with torch.no_grad():
        for X, y in data_loader:
            X = X.to(device)
            y = y.to(device)

            output = model(X)

            predictions.append(output.cpu())
            targets.append(y.cpu())

    predictions_tensor = torch.cat(predictions)
    targets_tensor = torch.cat(targets)

    predictions_chf = predictions_tensor * target_std + target_mean

    targets_chf = targets_tensor * target_std + target_mean

    errors = predictions_chf - targets_chf

    mae = torch.mean(torch.abs(errors)).item()
    rmse = torch.sqrt(torch.mean(errors**2)).item()

    target_sum_of_squares = torch.sum((targets_chf - targets_chf.mean()) ** 2)

    residual_sum_of_squares = torch.sum(errors**2)

    if target_sum_of_squares.item() == 0:
        r2 = 0.0
    else:
        r2 = (1 - residual_sum_of_squares / target_sum_of_squares).item()

    return {
        "mae": mae,
        "rmse": rmse,
        "r2": r2,
    }


def train_model(
    model: nn.Module,
    train_loader: DataLoader,
    validation_loader: DataLoader,
    device: torch.device,
    learning_rate: float,
    weight_decay: float,
    max_epochs: int,
    patience: int,
) -> tuple[nn.Module, int]:
    criterion = nn.MSELoss()

    optimizer = torch.optim.AdamW(
        model.parameters(),
        lr=learning_rate,
        weight_decay=weight_decay,
    )

    best_validation_loss = float("inf")
    best_model_state = None
    best_epoch = 0
    epochs_without_improvement = 0

    for epoch in range(1, max_epochs + 1):
        model.train()

        total_train_loss = 0.0
        total_samples = 0

        for X, y in train_loader:
            X = X.to(device)
            y = y.to(device)

            optimizer.zero_grad()

            predictions = model(X)
            loss = criterion(predictions, y)

            loss.backward()
            optimizer.step()

            current_batch_size = X.size(0)

            total_train_loss += loss.item() * current_batch_size
            total_samples += current_batch_size

        train_loss = total_train_loss / total_samples

        validation_loss = compute_loss(
            model,
            validation_loader,
            criterion,
            device,
        )

        print(
            f"Epoch {epoch:03d} | "
            f"Train loss: {train_loss:.4f} | "
            f"Validation loss: {validation_loss:.4f}"
        )

        if validation_loss < best_validation_loss:
            best_validation_loss = validation_loss
            best_model_state = deepcopy(model.state_dict())
            best_epoch = epoch
            epochs_without_improvement = 0
        else:
            epochs_without_improvement += 1

        if epochs_without_improvement >= patience:
            print(f"Early stopping at epoch {epoch}.")
            break

    if best_model_state is None:
        raise RuntimeError("No model state was saved.")

    model.load_state_dict(best_model_state)

    return model, best_epoch


def train(
    data_path: Path,
    random_seed: int,
    train_ratio: float,
    validation_ratio: float,
    test_ratio: float,
    batch_size: int,
    learning_rate: float,
    weight_decay: float,
    max_epochs: int,
    patience: int,
) -> dict:
    if not np.isclose(
        train_ratio + validation_ratio + test_ratio,
        1.0,
    ):
        raise ValueError("Train, validation and test ratios must sum to 1.")

    set_seed(random_seed)
    device = get_device()
    df = pd.read_csv(data_path)

    train_df, validation_df, test_df = split_data(
        df,
        train_ratio,
        validation_ratio,
        test_ratio,
        random_seed,
    )

    print(f"Device: {device}")
    print(f"Total samples: {len(df)}")
    print(f"Training samples: {len(train_df)}")
    print(f"Validation samples: {len(validation_df)}")
    print(f"Test samples: {len(test_df)}")

    (
        preprocessor,
        train_dataset,
        validation_dataset,
        test_dataset,
        target_mean,
        target_std,
    ) = prepare_data(
        train_df,
        validation_df,
        test_df,
    )

    train_loader, validation_loader, test_loader = create_loaders(
        train_dataset,
        validation_dataset,
        test_dataset,
        batch_size,
        random_seed,
    )
    model = SalaryModel(
        input_dim=preprocessor.input_dim,
    ).to(device)

    model, best_epoch = train_model(
        model,
        train_loader,
        validation_loader,
        device,
        learning_rate,
        weight_decay,
        max_epochs,
        patience,
    )
    validation_metrics = evaluate(
        model,
        validation_loader,
        device,
        target_mean,
        target_std,
    )
    test_metrics = evaluate(
        model,
        test_loader,
        device,
        target_mean,
        target_std,
    )

    print(f"Best epoch: {best_epoch}")
    print(f"Validation MAE: {validation_metrics['mae']:.2f} CHF")
    print(f"Validation RMSE: {validation_metrics['rmse']:.2f} CHF")
    print(f"Validation R2: {validation_metrics['r2']:.4f}")
    print(f"Test MAE: {test_metrics['mae']:.2f} CHF")
    print(f"Test RMSE: {test_metrics['rmse']:.2f} CHF")
    print(f"Test R2: {test_metrics['r2']:.4f}")

    return {
        "model": model.cpu(),
        "preprocessor": preprocessor,
        "target_mean": target_mean,
        "target_std": target_std,
        "statistics": {
            "best_epoch": best_epoch,
            "validation": validation_metrics,
            "test": test_metrics,
            "train_samples": len(train_df),
            "validation_samples": len(validation_df),
            "test_samples": len(test_df),
            "parameters": {
                "random_seed": random_seed,
                "train_ratio": train_ratio,
                "validation_ratio": validation_ratio,
                "test_ratio": test_ratio,
                "batch_size": batch_size,
                "learning_rate": learning_rate,
                "weight_decay": weight_decay,
                "max_epochs": max_epochs,
                "patience": patience,
            },
        },
    }
