import pandas as pd
from pathlib import Path

from encoding import encode_data
from preprocessing import preprocess

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR.joinpath("data", "swiss_job_offers.csv")
RESULTS_PATH = BASE_DIR.joinpath("results")
VISUALIZATION_PATH = BASE_DIR.joinpath("visualization")

TRAIN_RATIO = 0.7
VALIDATION_RATIO = 0.15
TEST_RATIO = 0.15

RANDOM_SEED = 42


def main():
    # load dataset
    df = pd.read_csv(DATA_PATH)

    # preprocess dataset (e.g., handle missing values, encode categorical variables, etc.)
    df = preprocess(df)

    # encode dataset
    df = encode_data(df)

    # split dataset into train, validation, and test sets
    train_df = df.sample(frac=TRAIN_RATIO, random_state=RANDOM_SEED)
    remaining_df = df.drop(train_df.index)
    validation_df = remaining_df.sample(frac=VALIDATION_RATIO, random_state=RANDOM_SEED)
    test_df = remaining_df.drop(validation_df.index)


if __name__ == "__main__":
    main()
