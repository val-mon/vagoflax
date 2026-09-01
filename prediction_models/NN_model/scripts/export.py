from pathlib import Path

import torch
import litert_torch

from scripts.model import SalaryModel


def export_tflite(
    model: SalaryModel,
    input_dim: int,
    output_path: Path,
) -> None:
    model = model.cpu().eval()

    sample_inputs = (
        torch.zeros(
            1,
            input_dim,
            dtype=torch.float32,
        ),
    )

    with torch.no_grad():
        edge_model = litert_torch.convert(
            model,
            sample_inputs,
        )

    edge_model.export(str(output_path))