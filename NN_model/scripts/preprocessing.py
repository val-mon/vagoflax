from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import pandas as pd
import torch
from torch import Tensor
from torch.utils.data import TensorDataset


TARGET_COLUMN = "SalaryCHF"

DROP_COLUMNS = [
    "MaternityLeaveWeeks",
    "PaternityLeaveWeeks",
]

ONE_HOT_COLUMNS = [
    "Role",
    "Industry",
    "Canton",
    "CompanySize",
]

MULTI_HOT_COLUMNS = [
    "Diploma",
    "Perks",
    "Languages",
]

SCALED_NUMERIC_COLUMNS = [
    "MinYearsExperience",
    "ContractMonths",
    "Holidays",
    "WorkloadPercent",
]

BINARY_COLUMNS = [
    "IsPermanent",
]

UNKNOWN_TOKEN = "__UNKNOWN__"




def parse_min_experience_value(value: object) -> float:
    """
    Transform "4 to 6" into (4.0, 6.0).
    """
    if pd.isna(value):
        return np.nan

    text = str(value).strip()

    try:
        parts = text.split("to")

        if len(parts) != 2:
            raise ValueError

        min_years = float(parts[0].strip())

        return min_years

    except (ValueError, IndexError) as exc:
        raise ValueError(
            f"Invalid MinYearsExperience value: {value!r}"
        ) from exc


def parse_contract_months_value(value: object) -> float:
    """
    Convert a contract length string into a number of months.

    "6 months" -> 6
    "1 year" -> 12
    "2 years" -> 24
    "Permanent" -> 0
    """
    if pd.isna(value):
        return np.nan

    text = str(value).strip().lower()

    if text == "permanent":
        return 0.0

    parts = text.split()

    if len(parts) < 2:
        raise ValueError(
            f"Invalid Contract value: {value!r}"
        )

    try:
        quantity = float(parts[0])
    except ValueError as exc:
        raise ValueError(
            f"Invalid Contract value: {value!r}"
        ) from exc

    unit = parts[1]

    if unit.startswith("month"):
        return quantity

    if unit.startswith("year"):
        return quantity * 12.0

    raise ValueError(
        f"Invalid Contract value: {value!r}"
    )


def split_multi_value(value: object) -> list[str]:
    """
    Split a multi-value string into a list of strings.

    "English, German" -> ["English", "German"]
    """
    if pd.isna(value):
        return []

    return [
        part.strip()
        for part in str(value).split(",")
        if part.strip()
    ]


def basic_cleanup(df: pd.DataFrame) -> pd.DataFrame:
    """
    Apply deterministic cleanup before fitting or transforming.

    - Delete paternity and maternity leave columns.
    - Split MinYearsExperience into minimum experience.
    - Convert Contract into ContractMonths and IsPermanent.
    - Replace missing Perks with an explicit "None" category.
    """
    result = df.copy()

    result = result.drop(
        columns=DROP_COLUMNS,
        errors="ignore",
    )

    if "MinYearsExperience" in result.columns:
        experience = result["MinYearsExperience"].apply(
            parse_min_experience_value
        )

        result["MinYearsExperience"] = experience


    if "Contract" in result.columns:
        contract_values = result["Contract"].astype("string")

        result["IsPermanent"] = (
            contract_values
            .str.strip()
            .str.lower()
            .eq("permanent")
            .fillna(False)
            .astype(np.float32)
        )

        result["ContractMonths"] = result["Contract"].map(
            parse_contract_months_value
        )

        result = result.drop(
            columns="Contract"
        )

    if "Perks" in result.columns:
        result["Perks"] = result["Perks"].fillna(
            UNKNOWN_TOKEN
        )

    return result


@dataclass
class JobOfferPreprocessor:
    """
    Preprocessor used to prepare job offer data for PyTorch.

    Scaled numeric features:
        - MinYearsExperience
        - ContractMonths
        - Holidays
        - WorkloadPercent

    Binary features:
        - IsPermanent

    One-hot features:
        - Role
        - Industry
        - Canton
        - CompanySize

    Multi-hot features:
        - Diploma
        - Perks
        - Languages
    """

    scale_numeric: bool = True
    add_unknown_category: bool = True

    one_hot_categories_: dict[str, list[str]] = field(
        default_factory=dict,
        init=False,
    )

    multi_hot_categories_: dict[str, list[str]] = field(
        default_factory=dict,
        init=False,
    )

    numeric_means_: dict[str, float] = field(
        default_factory=dict,
        init=False,
    )

    numeric_stds_: dict[str, float] = field(
        default_factory=dict,
        init=False,
    )

    feature_names_: list[str] = field(
        default_factory=list,
        init=False,
    )

    fitted_: bool = field(
        default=False,
        init=False,
    )

    def fit(
        self,
        df: pd.DataFrame,
    ) -> "JobOfferPreprocessor":
        """
        Learn categories and numeric statistics from the training data.
        """
        cleaned = basic_cleanup(df)

        self._validate_columns(
            cleaned,
            require_target=False,
        )

        self.one_hot_categories_.clear()
        self.multi_hot_categories_.clear()
        self.numeric_means_.clear()
        self.numeric_stds_.clear()

        for column in ONE_HOT_COLUMNS:
            categories = sorted(
                cleaned[column]
                .dropna()
                .astype(str)
                .unique()
                .tolist()
            )

            if (
                self.add_unknown_category
                and UNKNOWN_TOKEN not in categories
            ):
                categories.append(UNKNOWN_TOKEN)

            self.one_hot_categories_[column] = categories

        for column in MULTI_HOT_COLUMNS:
            self.multi_hot_categories_[column] = (
                self._collect_multi_categories(
                    cleaned[column]
                )
            )

        for column in SCALED_NUMERIC_COLUMNS:
            values = pd.to_numeric(
                cleaned[column],
                errors="coerce",
            ).astype(float)

            mean = float(values.mean())

            if np.isnan(mean):
                mean = 0.0

            std = float(
                values.std(ddof=0)
            )

            if np.isnan(std) or std == 0.0:
                std = 1.0

            self.numeric_means_[column] = mean
            self.numeric_stds_[column] = std

        self.feature_names_ = self._build_feature_names()

        self.fitted_ = True

        return self

    def transform(
        self,
        df: pd.DataFrame,
    ) -> pd.DataFrame:
        """
        Transform a DataFrame into a purely numeric feature matrix.

        Returned columns always follow the order learned during fit().
        """
        self._check_fitted()

        cleaned = basic_cleanup(df)

        self._validate_columns(
            cleaned,
            require_target=False,
        )

        output = pd.DataFrame(
            index=cleaned.index
        )

        for column in SCALED_NUMERIC_COLUMNS:
            values = pd.to_numeric(
                cleaned[column],
                errors="coerce",
            ).astype(float)

            values = values.fillna(
                self.numeric_means_[column]
            )

            if self.scale_numeric:
                values = (
                    values
                    - self.numeric_means_[column]
                ) / self.numeric_stds_[column]

            output[column] = values.astype(
                np.float32
            )

        for column in BINARY_COLUMNS:
            values = pd.to_numeric(
                cleaned[column],
                errors="coerce",
            ).astype(float)

            values = values.fillna(0.0)

            output[column] = values.astype(
                np.float32
            )

        for column in ONE_HOT_COLUMNS:
            categories = self.one_hot_categories_[column]

            series = cleaned[column].astype(
                "string"
            )

            known_categories = {
                category
                for category in categories
                if category != UNKNOWN_TOKEN
            }

            for category in categories:
                feature_name = (
                    f"{column}__{category}"
                )

                if category == UNKNOWN_TOKEN:
                    is_unknown = (
                        series.notna()
                        & ~series.isin(
                            known_categories
                        )
                    )

                    output[feature_name] = (
                        is_unknown.astype(
                            np.float32
                        )
                    )

                else:
                    output[feature_name] = (
                        (series == category)
                        .fillna(False)
                        .astype(np.float32)
                    )

        for column in MULTI_HOT_COLUMNS:
            categories = (
                self.multi_hot_categories_[column]
            )

            parsed_values = cleaned[column].apply(
                split_multi_value
            )

            value_sets = parsed_values.apply(set)

            for category in categories:
                feature_name = (
                    f"{column}__{category}"
                )

                output[feature_name] = (
                    value_sets.apply(
                        lambda values: float(
                            category in values
                        )
                    ).astype(np.float32)
                )

        output = output[
            self.feature_names_
        ]

        return output

    def fit_transform(
        self,
        df: pd.DataFrame,
    ) -> pd.DataFrame:
        return self.fit(df).transform(df)

    def transform_to_tensors(
        self,
        df: pd.DataFrame,
    ) -> tuple[Tensor, Tensor | None]:
        """
        Transform a DataFrame into PyTorch tensors.

        X has shape (n_samples, n_features).
        y has shape (n_samples, 1).

        If SalaryCHF is absent, y is None.
        """
        features = self.transform(df)

        X = torch.tensor(
            features.to_numpy(
                dtype=np.float32
            ),
            dtype=torch.float32,
        )

        y = None

        if TARGET_COLUMN in df.columns:
            target = pd.to_numeric(
                df[TARGET_COLUMN],
                errors="raise",
            )

            y = torch.tensor(
                target.to_numpy(
                    dtype=np.float32
                ),
                dtype=torch.float32,
            ).reshape(-1, 1)

        return X, y

    def transform_to_dataset(
        self,
        df: pd.DataFrame,
    ) -> TensorDataset:
        X, y = self.transform_to_tensors(df)

        if y is None:
            raise ValueError(
                f"Target column {TARGET_COLUMN!r} "
                "is missing from the DataFrame."
            )

        return TensorDataset(X, y)

    def to_dict(self) -> dict:
        self._check_fitted()

        return {
            "feature_names": self.feature_names,
            "scaled_numeric_columns": (
                SCALED_NUMERIC_COLUMNS.copy()
            ),
            "binary_columns": (
                BINARY_COLUMNS.copy()
            ),
            "one_hot_categories": (
                self.one_hot_categories_
            ),
            "multi_hot_categories": (
                self.multi_hot_categories_
            ),
            "numeric_means": (
                self.numeric_means_
            ),
            "numeric_stds": (
                self.numeric_stds_
            ),
            "scale_numeric": self.scale_numeric,
            "add_unknown_category": (
                self.add_unknown_category
            ),
        }

    @staticmethod
    def _collect_multi_categories(
        series: pd.Series,
    ) -> list[str]:
        categories: set[str] = set()

        for value in series:
            categories.update(
                split_multi_value(value)
            )

        return sorted(categories)

    def _build_feature_names(
        self,
    ) -> list[str]:
        features: list[str] = []

        features.extend(
            SCALED_NUMERIC_COLUMNS
        )

        features.extend(
            BINARY_COLUMNS
        )

        for column in ONE_HOT_COLUMNS:
            for category in (
                self.one_hot_categories_[column]
            ):
                features.append(
                    f"{column}__{category}"
                )

        for column in MULTI_HOT_COLUMNS:
            for category in (
                self.multi_hot_categories_[column]
            ):
                features.append(
                    f"{column}__{category}"
                )

        return features

    @staticmethod
    def _validate_columns(
        df: pd.DataFrame,
        require_target: bool,
    ) -> None:
        required = set(
            ONE_HOT_COLUMNS
            + MULTI_HOT_COLUMNS
            + SCALED_NUMERIC_COLUMNS
            + BINARY_COLUMNS
        )

        if require_target:
            required.add(
                TARGET_COLUMN
            )

        missing = sorted(
            required.difference(
                df.columns
            )
        )

        if missing:
            raise KeyError(
                "Required columns are missing: "
                + ", ".join(missing)
            )

    def _check_fitted(self) -> None:
        if not self.fitted_:
            raise RuntimeError(
                "JobOfferPreprocessor must be fitted "
                "before calling transform()."
            )

    @property
    def input_dim(self) -> int:
        self._check_fitted()

        return len(
            self.feature_names_
        )

    @property
    def feature_names(
        self,
    ) -> list[str]:
        self._check_fitted()

        return self.feature_names_.copy()
