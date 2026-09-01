import unittest

import pandas as pd

from scripts.preprocessing import JobOfferPreprocessor


class JobOfferPreprocessorTest(unittest.TestCase):
    def setUp(self):
        self.data = pd.DataFrame(
            {
                "Diploma": ["Bachelor", "Master"],
                "MinYearsExperience": ["1 to 3", "4 to 6"],
                "Role": ["Junior", "Senior"],
                "Contract": ["12 months", "Permanent"],
                "Industry": ["IT", "Finance"],
                "Canton": ["ZH", "GE"],
                "Perks": ["Car", "Meal vouchers"],
                "CompanySize": ["Startup (<50)", "Large (1000+)"],
                "Languages": ["English", "French, German"],
                "Holidays": [20, 25],
                "WorkloadPercent": [100, 80],
                "SalaryCHF": [80000, 120000],
            }
        )

    def test_uses_only_the_supported_one_hot_columns(self):
        preprocessor = JobOfferPreprocessor().fit(self.data)

        self.assertEqual(
            set(preprocessor.one_hot_categories_),
            {"Role", "Industry", "Canton", "CompanySize"},
        )

    def test_multiple_diplomas_are_encoded_independently(self):
        preprocessor = JobOfferPreprocessor().fit(self.data)
        offer = self.data.iloc[[0]].copy()
        offer.loc[offer.index[0], "Diploma"] = "Bachelor, Master"

        transformed = preprocessor.transform(offer).iloc[0]

        self.assertEqual(transformed["Diploma__Bachelor"], 1.0)
        self.assertEqual(transformed["Diploma__Master"], 1.0)


if __name__ == "__main__":
    unittest.main()
