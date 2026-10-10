"""Unit tests for the synthetic check-in portfolio demo.

Run from repository root:
python -m unittest discover -s portfolio/tests -v
"""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from checkin_transform_demo import normalise_checkins


class TestCheckinTransform(unittest.TestCase):
    def test_explodes_timestamps(self):
        rows, metrics = normalise_checkins([{
            "business_id": " A ",
            "date": "2024-01-05 18:30:00, 2024-01-06 12:00:00",
        }])
        self.assertEqual(len(rows), 2)
        self.assertEqual(metrics["valid_checkins"], 2)
        self.assertEqual(rows[0]["business_id"], "A")
        self.assertEqual(rows[0]["hour"], 18)

    def test_invalid_and_missing(self):
        rows, metrics = normalise_checkins([
            {"business_id": "A", "date": "invalid, 2024-01-05 18:30:00"},
            {"business_id": "", "date": "2024-01-05 18:30:00"},
        ])
        self.assertEqual(len(rows), 1)
        self.assertEqual(metrics["invalid_timestamps"], 1)
        self.assertEqual(metrics["missing_business_ids"], 1)

    def test_repeats_are_flagged_not_deleted(self):
        rows, metrics = normalise_checkins([{
            "business_id": "A",
            "date": "2024-01-05 18:30:00, 2024-01-05 18:30:00",
        }])
        self.assertEqual(len(rows), 2)
        self.assertEqual(metrics["repeated_business_timestamp_pairs"], 1)

    def test_empty_input(self):
        rows, metrics = normalise_checkins([])
        self.assertEqual(rows, [])
        self.assertEqual(metrics, {})


if __name__ == "__main__":
    unittest.main()
