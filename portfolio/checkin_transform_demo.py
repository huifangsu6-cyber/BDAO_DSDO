"""Small, local, read-only demo inspired by the Yelp check-in transformation.

Portfolio adaptation, NOT an original coursework deliverable.
Uses invented example data (not Yelp records), no cloud account required.
Run: python portfolio/checkin_transform_demo.py
"""
from __future__ import annotations

from collections import Counter
from datetime import datetime
from typing import Iterable

TIME_FORMAT = "%Y-%m-%d %H:%M:%S"


def normalise_checkins(records: Iterable[dict[str, str]]) -> tuple[list[dict], dict]:
    """Split comma-delimited check-in timestamps into one row per event.

    Keeps repeated events visible instead of silently deleting them.
    Invalid timestamps are counted and excluded from the valid output.
    """
    cleaned: list[dict] = []
    metrics = Counter()
    seen: set[tuple[str, str]] = set()

    for record in records:
        metrics["source_business_rows"] += 1
        business_id = (record.get("business_id") or "").strip()
        if not business_id:
            metrics["missing_business_ids"] += 1
            continue

        for raw in (record.get("date") or "").split(","):
            timestamp = raw.strip()
            if not timestamp:
                continue
            metrics["timestamp_tokens"] += 1
            try:
                parsed = datetime.strptime(timestamp, TIME_FORMAT)
            except ValueError:
                metrics["invalid_timestamps"] += 1
                continue

            key = (business_id, parsed.isoformat())
            if key in seen:
                metrics["repeated_business_timestamp_pairs"] += 1
            seen.add(key)
            cleaned.append({
                "business_id": business_id,
                "checkin_timestamp": parsed.isoformat(sep=" "),
                "weekday": parsed.strftime("%A"),
                "hour": parsed.hour,
            })
            metrics["valid_checkins"] += 1

    return cleaned, dict(metrics)


if __name__ == "__main__":
    example = [
        {"business_id": "restaurant_A", "date": "2024-01-05 18:30:00, 2024-01-06 12:00:00"},
        {"business_id": "restaurant_B", "date": "bad-timestamp, 2024-01-05 18:30:00"},
        {"business_id": "", "date": "2024-01-07 09:00:00"},
    ]
    rows, quality = normalise_checkins(example)
    print("Example transformed rows:", rows)
    print("Data quality profile:", quality)
