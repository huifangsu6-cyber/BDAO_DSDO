# Portfolio walkthrough: Yelp analytics pipeline

This guide is a **recruiter-facing reading path** through the existing project. It does not replace or rewrite the original coursework notebooks.

## 5-minute review

1. **Pipeline implementation:** [main project notebook](../BDAO_group_project_yelp-3.ipynb) — inspect the Google Cloud / BigQuery ingestion, table checks and transformation cells.
2. **SQL analysis:** [query collection](../sql/) — individual files for restaurant attributes, pricing, opening hours, check-in activity and review themes.
3. **Analysis and results:** [summary notebook](../huifang_yelp_summary_analysis_en.ipynb) and [saved outputs](../outputs/).
4. **Full context:** [project report](../NROA_Restaurant_Success_Index_Report_1.docx).

## What I built

- Designed the workflow to ingest multiple Yelp JSON datasets using Google Cloud Storage and BigQuery.
- Wrote the pipeline and analysis code, including data-quality checks and SQL transformations.
- Prepared nested and timestamp-based source fields for structured downstream analysis.

The broader restaurant-success research was a university group assignment. The pipeline/code authorship above describes my personal contribution.

## How to evaluate this work

| Skill | Evidence to inspect | What not to infer |
| --- | --- | --- |
| Data engineering | Main notebook, ingestion and transformation cells | Not a continuously operated production ETL service |
| SQL | `sql/` queries | Queries may require the original BigQuery tables |
| Data validation | Checks in main notebook | No independently measured error-rate reduction is claimed |
| Analytics | Summary and extended notebooks | Observational associations are not causal effects |
| Communication | Project report and outputs | Recommendations are not documented revenue gains |

## Running the notebooks

The original notebooks depend on a Google Cloud environment and Yelp source data. To reproduce the full workflow, a reviewer would need to supply their own authorised data access, cloud project, dataset identifiers and credentials. **Do not place credentials in notebook cells or version control.**

This repository is intended to show actual code, transformations, analytical thinking and reporting rather than promise a turnkey local reproduction.

## Portfolio design references

The documentation approach takes inspiration from the concise project explanation in [Streamlit's repository](https://github.com/streamlit/streamlit) and the explicit notebook navigation / getting-started guidance in [Hands-on Machine Learning notebooks](https://github.com/ageron/handson-ml3). No code has been copied from those projects.
