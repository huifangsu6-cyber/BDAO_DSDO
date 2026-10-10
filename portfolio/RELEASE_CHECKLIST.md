# Portfolio release checklist (reviewed 10 October 2026)

## Repository structure

The GitHub tree API returned a complete, non-truncated listing of **61 files** on the portfolio branch, compared with **47 files** on `main`. The branch adds portfolio documentation and examples without deleting the original coursework artefacts.

The top-level README links were checked against this tree: all **11 relative destinations** resolve to files or existing directories (including `sql/` and `outputs/`). This is a **path-existence check**, not a full rendered-page or external-link test.

## Specific publication risks

| Priority | Observation | Action before merging |
| --- | --- | --- |
| High | The public repository contains multiple coursework/tutorial notebooks, including answer/example files in `Week 1/` and `Week 2/`. | Confirm the right to republish teaching material. Consider a separate portfolio repository with only authorised personal work. |
| High | `outputs/tables/q8_restaurant_hours_export.csv` is ~9.7 MB. The content was not successfully inspected in this review. | Review for personal/sensitive data, permissions and whether publishing a large raw export is necessary. |
| High | Notebook outputs, documents and Git history have **not** undergone a complete secret/privacy audit. | Do not describe the repository as fully security-cleared. Review all files and history before advertising it publicly. |
| Medium | Several output CSVs have `.csv.csv` suffixes. | Consider renaming in a future clean-up, but update any links and avoid rewriting source evidence casually. |
| Medium | The repository mixes original coursework, tutorials, reports, SQL and later portfolio examples. | Keep the README focused on personally owned GCS/BigQuery integration; label adaptations separately. |
| Medium | Some original SQL describes observational rating differences as a “boost”. | Interpret as associations, not causal effects. |

## What was checked

- Compared complete GitHub repository tree listings for `main` and the portfolio branch.
- Verified README's internal destination paths exist.
- Inspected selected SQL and the report skeleton.
- Kept the personal contribution statement limited to the owner's confirmed cloud-data organisation and integration responsibilities.

## What was NOT checked

- Full contents of the 9.7 MB CSV export or all notebook saved outputs.
- All Git history, binary documents, licence terms or cloud permissions.
- Execution of the original BigQuery queries against the source data.
- End-to-end performance or accuracy of the original pipeline.

## Release decision

**HOLD / do not merge yet.** The documentation and navigation are improved, but the open questions about coursework redistribution and public data exposure should be resolved before treating this as a recruiter-ready public repository.

## Safer release option

If the original coursework/tutorial material cannot be cleared for public sharing, publish a **separate curated portfolio repository** containing only the owner's authorised GCS/BigQuery integration case study, non-sensitive diagrams and explicitly labelled synthetic examples. Preserve the original repository privately for reference, subject to GitHub visibility and collaboration considerations.
