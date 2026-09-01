from datetime import datetime
import json
from pathlib import Path

import torch

from scripts.export import export_tflite


def save_result(
    result: dict,
    results_dir: Path,
) -> Path:
    result_name = datetime.now().strftime(
        "result_%Y-%m-%d_%H-%M-%S"
    )

    result_dir = results_dir / result_name
    result_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    model = result["model"]
    preprocessor = result["preprocessor"]

    model_path = result_dir / "model.pt"
    statistics_path = result_dir / "statistics.json"
    preprocessing_path = result_dir / "preprocessing.json"
    tflite_path = result_dir / "model.tflite"

    torch.save(
        {
            "model_state_dict": model.state_dict(),
            "input_dim": preprocessor.input_dim,
        },
        model_path,
    )

    with open(
        statistics_path,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            result["statistics"],
            file,
            indent=4,
        )

    preprocessing_data = preprocessor.to_dict()

    preprocessing_data["target_mean"] = result["target_mean"]
    preprocessing_data["target_std"] = result["target_std"]

    with open(
        preprocessing_path,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            preprocessing_data,
            file,
            indent=4,
        )

    export_tflite(
        model=model,
        input_dim=preprocessor.input_dim,
        output_path=tflite_path,
    )

    return result_dir