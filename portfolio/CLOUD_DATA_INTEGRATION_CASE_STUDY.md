# Cloud Data Integration & Data Governance
### My contribution to the Yelp Restaurant Analytics project

**Role:** Cloud data preparation and integration (individual contribution within a group project)  
**Stack:** Google Cloud Storage (GCS), Google BigQuery, CSV/JSON, Python/SQL downstream

## Problem

The team needed a consistent, accessible data foundation before separate members could analyse Yelp business attributes, reviews and check-ins. Raw datasets differed in purpose, structure and size, making ad-hoc file sharing and ambiguous versions a risk.

## What I personally did

1. **Source-file inventory and standardisation.** Reviewed and organised the raw Yelp files by dataset type and intended use. Applied consistent filenames, removed redundant or irrelevant copies, checked the CSV/JSON formats, and identified which file version should be treated as authoritative.
2. **Cloud storage organisation.** Established the GCS bucket/folder structure for shared datasets, separating sources by type and intended analytical use.
3. **Schema readiness.** Inspected fields and dataset schemas to prepare files for downstream processing and BigQuery loading.
4. **Shared data integration.** Designed the GCS-to-BigQuery workflow and set up the cloud data-loading/table structure used by the team.
5. **Team hand-off.** Assigned the appropriate prepared datasets to teammates working on their own cleaning and analytical questions.

These are the project owner's confirmed contributions. **Dataset-specific review and check-in transformations and analytical findings were produced in the collaborative workstreams**, not claimed here as my personal code.

## Workflow and responsibility boundary

```text
RAW YELP DATASETS
      |
      | My work: inspect, organise, standardise filenames/formats,
      | remove redundant copies, select final versions, check schema
      v
GOOGLE CLOUD STORAGE
      |
      | My work: bucket/folder organisation and shared data access
      v
BIGQUERY
      |
      | My work: data integration, loading and table structure
      v
SHARED ANALYTICS DATA FOUNDATION
      |
      +--> Teammate workstream: review cleaning and analysis
      +--> Teammate workstream: check-in cleaning and analysis
      +--> Other collaborative SQL/Python analysis and reporting
```

## Practical controls I used

| Data-management concern | How I addressed it | Why it matters |
| --- | --- | --- |
| Inconsistent file naming | Standardised names by source/type | Easier identification and hand-off |
| Multiple candidate versions | Identified final versions and removed unnecessary duplicates | Reduces risk of conflicting inputs |
| Mixed file formats | Organised and checked CSV/JSON files | Supports predictable ingestion |
| Dataset ambiguity | Classified files by analytical purpose | Helps colleagues locate the right source |
| Schema mismatch risk | Inspected fields and schema | Makes downstream BigQuery preparation easier |
| Distributed teamwork | Allocated prepared datasets to workstreams | Establishes a common source for analysis |

These are **workflow controls**, not claims of automated enterprise data governance or quantified error reduction.

## Evidence and limitations

- [Original collaborative notebook](../BDAO_group_project_yelp-3.ipynb) shows the shared Google Cloud / BigQuery environment and subsequent analysis.
- [Original SQL queries](../sql/) show how the resulting datasets were used by the project.
- [Project report](../NROA_Restaurant_Success_Index_Report_1.docx) documents the wider business analysis.

**Evidence boundary:** The public repository contains collaborative project artefacts. It does not independently establish every GCS folder naming decision, source-file deduplication action, access assignment or historical cloud configuration. The detailed responsibilities above are based on the owner's direct account, not a forensic reconstruction of Google Cloud audit logs.

## Interview-ready summary

> I was responsible for the data foundation of a Yelp analytics group project. I organised and standardised the raw files in Google Cloud Storage, checked formats and schemas, selected final dataset versions, and set up the GCS-to-BigQuery integration and table structure. That gave other team members consistent data sources for their SQL and Python analysis. I distinguish that infrastructure work from the dataset-specific transformations and insights produced by the group.

## Reproducibility

This is an explanation of **work actually undertaken**, not a newly deployed pipeline. Recreating the cloud infrastructure requires the original authorised datasets, GCP configuration and access rights. No credentials are published here.
