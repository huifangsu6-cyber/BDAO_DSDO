# Runnable check-in transformation demonstration

**Purpose:** Show a compact, locally executable version of the *transformation pattern* used in the Yelp coursework: split comma-separated timestamp strings, validate values, produce one event row per timestamp and report data-quality exceptions.

**Important:** This is a **new, synthetic portfolio adaptation** created to make the approach easy to inspect. It is not copied verbatim from the original notebook, does not use real Yelp records and does not prove that the cloud pipeline has been executed again.

## Quick start

Python 3.10+ is sufficient; there are **no external dependencies**.

```bash
python portfolio/checkin_transform_demo.py
python -m unittest discover -s portfolio/tests -v
```

The demo prints transformed example rows and a small quality profile. The tests cover timestamp expansion, malformed timestamps, missing business IDs, duplicate-key detection and empty input.

## Data contract

Input is a sequence of mappings with `business_id` and a `date` string containing comma-separated timestamps in `YYYY-MM-DD HH:MM:SS` format.

Output is a list of `business_id`, `checkin_timestamp`, `weekday`, and `hour` records, plus counts of input rows, tokens, valid check-ins and exceptions.

Repeated business/timestamp pairs are **flagged, not automatically deleted**. Timezone conversion is not attempted because the synthetic inputs contain no timezone information.

## Relationship to original work

- Original cloud pipeline: [coursework notebook](../BDAO_group_project_yelp-3.ipynb).
- Original SQL: [queries](../sql/).
- Cloud-dependent read-only profiling: [BigQuery example](read_only_checkin_profile.py).

This demonstration is intentionally small enough for a recruiter to run without Google Cloud access.
