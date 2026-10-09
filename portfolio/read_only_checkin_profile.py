"""Recruiter-facing example adapted from the Yelp coursework workflow.

Shows safe, read-only data profiling in Google BigQuery.
This is a NEW portfolio adaptation, not a verbatim original project deliverable.
Requires: pip install google-cloud-bigquery
Authentication: use Application Default Credentials or a managed runtime.
Never commit credentials.
"""

from __future__ import annotations

import os
from google.cloud import bigquery


def profile_checkins(project_id: str, dataset_id: str) -> dict:
    """Return read-only quality metrics for the cleaned check-in table.

    Requires a trusted BigQuery project/dataset ID from the caller.
    No table creation, replacement or mutation is performed.
    """
    if not project_id or not dataset_id:
        raise ValueError("Project and dataset IDs are required.")

    # BigQuery identifier segments are deliberately restricted before interpolation.
    import re
    if not re.fullmatch(r"[a-z][a-z0-9-]{4,61}[a-z0-9]", project_id):
        raise ValueError("Unexpected Google Cloud project ID format.")
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", dataset_id):
        raise ValueError("Unexpected BigQuery dataset ID format.")

    client = bigquery.Client(project=project_id)
    table = f"`{project_id}.{dataset_id}.yelp_checkin_clean`"
    query = f"""
    SELECT
      COUNT(*) AS total_rows,
      COUNTIF(business_id IS NULL OR TRIM(business_id) = '') AS missing_business_ids,
      COUNTIF(checkin_timestamp IS NULL) AS invalid_or_missing_timestamps,
      COUNT(DISTINCT business_id) AS distinct_business_ids,
      MIN(checkin_timestamp) AS earliest_checkin,
      MAX(checkin_timestamp) AS latest_checkin
    FROM {table}
    """
    row = next(iter(client.query(query).result()))
    return dict(row.items())


if __name__ == "__main__":
    project = os.environ.get("GCP_PROJECT_ID", "")
    dataset = os.environ.get("BQ_DATASET_ID", "")
    print(profile_checkins(project, dataset))
