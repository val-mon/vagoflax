import json

import litert_torch
import torch


def save_preprocessing_metadata(
    X_train,
    scaler_X,
    scaler_y,
    columns_to_scale,
    one_hot_categories,
    multi_hot_categories,
    binary_columns,
    output_dir,
):
    metadata = {
        "feature_names": X_train.columns.tolist(),
        "scaled_numeric_columns": columns_to_scale,
        "binary_columns": binary_columns,
        "one_hot_categories": one_hot_categories,
        "multi_hot_categories": multi_hot_categories,
        "numeric_means": {
            column: float(mean)
            for column, mean in zip(columns_to_scale, scaler_X.mean_)
        },
        "numeric_stds": {
            column: float(scale)
            for column, scale in zip(columns_to_scale, scaler_X.scale_)
        },
        "scale_numeric": True,
        "add_unknown_category": True,
        "target_mean": float(scaler_y.mean_[0]),
        "target_std": float(scaler_y.scale_[0]),
    }

    output_path = output_dir.joinpath("preprocessing.json")

    with open(output_path, "w") as f:
        json.dump(metadata, f, indent=4)

def save_model(model, X_train_full, output_dir):
    model.eval()
    sample_input = torch.randn(1, X_train_full.shape[1], dtype=torch.float32)
    edge_model = litert_torch.convert(model, (sample_input,))
    model_path = output_dir.joinpath("model.tflite")
    edge_model.export(model_path)