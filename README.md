# Yelp Restaurant Analytics | Data Engineering & Business Insights

**Python · SQL · Google BigQuery · Google Cloud Storage · Data Quality · Analytics**

An end-to-end analytics project using Yelp business, review and check-in data to investigate factors associated with restaurant ratings and translate findings into practical recommendations.

> **My contribution:** I designed and built the data pipeline and wrote the associated data-processing and analysis code. The wider restaurant-success study was completed as a university group project.

## At a glance

| Area | Evidence |
| --- | --- |
| Data integration | Five Yelp JSON datasets brought into a Google Cloud Storage / BigQuery workflow |
| Data preparation | Parsing nested attributes and expanding check-in timestamps into approximately **8.5 million rows** |
| Quality assurance | Seven types of checks covering dataset shape, types, missing values, duplicates, descriptive statistics, uniqueness and spot checks |
| Analysis | Restaurant attributes, ratings, review text and check-in activity |
| Illustrative finding | Outdoor seating was **18.6 percentage points** more prevalent among higher-rated than lower-rated restaurants in the analysed sample |

These figures describe the academic project, **not** a production deployment or measured business impact. The outdoor-seating result is an association, not evidence of causation.

## Data workflow

```text
Yelp JSON source files
       |
       v
Google Cloud Storage
       |
       v
BigQuery ingestion and validation
       |
       +--> Data-quality checks
       |
       v
SQL cleaning and transformation
       |  - nested business attributes
       |  - check-in timestamp expansion
       v
Analysis-ready tables
       |
       v
Python / SQL exploratory and statistical analysis
       |
       v
Restaurant performance insights and recommendations
```

## Try the code locally (no cloud account required)

A small, **synthetic** adaptation of the check-in timestamp transformation is available in [the runnable demo](portfolio/DEMO_GUIDE.md). It includes [Python code](portfolio/checkin_transform_demo.py) and [unit tests](portfolio/tests/test_checkin_transform.py). This new demonstration is separate from the original coursework pipeline and does not use real Yelp data.

```bash
python portfolio/checkin_transform_demo.py
python -m unittest discover -s portfolio/tests -v
```

## Start here: evidence in this repository

| File or folder | What it demonstrates |
| --- | --- |
| [Main Yelp project notebook](BDAO_group_project_yelp-3.ipynb) | Data connection, validation, transformation and analysis workflow |
| [Summary analysis notebook](huifang_yelp_summary_analysis_en.ipynb) | Focused analytical exploration and reporting |
| [Extended analysis notebook](final%20report%20with%20fig%20q4-11.ipynb) | Further analysis and figures |
| [Opening-hours analysis](q8_opening_hours_alignment.ipynb) | A specific operational research question |
| [SQL folder](sql/) | SQL queries and transformations |
| [Outputs folder](outputs/) | Saved analysis outputs |
| [Project report](NROA_Restaurant_Success_Index_Report_1.docx) | Research context, methods and interpretation |

Some notebooks were developed in a cloud-connected teaching environment and may require access to the original datasets, Google Cloud credentials and configured BigQuery resources to rerun. They are shared primarily as **code and methodology evidence**, not as a guaranteed one-click executable package.

## Data quality and transformation

The workflow includes seven complementary checks:

1. Table shape and row counts
2. Data types and schema
3. Missing values
4. Duplicate records
5. Descriptive statistics and outliers
6. Unique values and category consistency
7. Manual spot checks

SQL transformations prepare nested JSON fields for analysis and expand timestamp strings from check-in data into individual time records. Validation is part of the process; no unverified percentage improvement in data quality is claimed.

## Business analysis

The project examined relationships between restaurant characteristics and ratings, alongside customer-review themes and check-in patterns. One observed difference was an **18.6 percentage-point** higher prevalence of outdoor seating in the higher-rated group. This result can inform hypotheses for operators, but does not show that adding outdoor seating causes higher ratings.

## Reproducibility and responsible sharing

- Source: Yelp data used in a university coursework setting; underlying data are not redistributed here.
- Runtime: Python notebooks, SQL, Google Cloud Storage and BigQuery.
- Outputs and findings reflect the project's dataset, filters and analytical definitions.
- Before reusing cloud queries, configure your own project, dataset names and credentials.
- **Never commit service-account keys, API tokens or private customer data.**

## Relevance to data analyst roles

This project demonstrates practical experience with messy multi-source data, cloud ingestion, SQL transformations, validation, analytical problem-solving and communicating results to non-technical stakeholders.

---
*Academic portfolio project; no claim of commercial deployment or realised revenue uplift.*
