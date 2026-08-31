from pathlib import Path

from scripts.artifacts import save_result
from scripts.train import train


BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "data" / "swiss_job_offers.csv"
RESULTS_DIR = BASE_DIR / "results"


def main():
    result = train(
        data_path=DATA_PATH,
        random_seed=42,
        train_ratio=0.70,
        validation_ratio=0.15,
        test_ratio=0.15,
        batch_size=8,
        learning_rate=1e-3,
        weight_decay=1e-3,
        max_epochs=3000,
        patience=500,
    )

    result_dir = save_result(
        result=result,
        results_dir=RESULTS_DIR,
    )

    print(f"Result saved to {result_dir}")


if __name__ == "__main__":
    main()