# Main notebook audit — initial pass

**Reviewed:** `BDAO_group_project_yelp-3.ipynb` (161 cells) using the locally supplied copy with matching project content. This is a static inspection, **not** an executed end-to-end test.

## Verified implementation details

| Notebook cells (0-based) | What the source actually contains |
| --- | --- |
| 2 | Google Colab authentication; Google Cloud Storage and BigQuery clients; helper functions `run_query` and `load_to_bq` |
| 8–25 | Sample-based reviews diagnostics: data types, missingness, duplicates, distribution charts |
| 34–84 | Check-in section: SQL transformation, table validation and time-based exploratory analysis |
| 55 | `CREATE OR REPLACE TABLE` with `UNNEST(SPLIT(date, ','))` and `SAFE.PARSE_TIMESTAMP` |
| 58 | Check-in row count, timestamp range and null timestamp count |
| 90–108 | User-table diagnostics and user-activity analysis |
| 115–158 | Tips-table quality checks and exploratory analysis |

The notebook contains **39 cells with saved outputs**, so it can provide evidence without requiring a reviewer to connect to the original cloud project.

## Important attribution note

This is a **collaborative notebook** and contains named section markers for different group members (including Jing, Yihe and others). It should **not** be presented as if every cell was personally authored by one person. The repository owner's account of personally designing/building the overall pipeline should be described separately from individual notebook-section authorship. When making specific personal-authorship claims, use independently identifiable files or commit history where possible.

## Preliminary sensitive-content scan

A scan of the **code/Markdown source cells in the local copy** found no matches for common private-key headers, Google API-key patterns, GitHub token prefixes, AWS access-key IDs, obvious literal password/token assignments or email-address patterns.

**This is not a security clearance.** Saved notebook outputs, other repository files, notebook history, unusual credential formats and linked resources have **not** been comprehensively reviewed. The notebook contains cloud project IDs and bucket names (configuration identifiers, not automatically credentials).

## Engineering review observations

- The setup assumes **Google Colab** and an authenticated Google Cloud account.
- The `load_to_bq` helper uses `if_exists='replace'`; it can overwrite destination tables.
- The check-in transformation uses `CREATE OR REPLACE TABLE`; running it also overwrites the named table.
- `SAFE.PARSE_TIMESTAMP` can produce NULLs for invalid strings; the follow-up NULL check is therefore relevant.
- Review visualisations based on a `LIMIT 50000` sample should be described as sample diagnostics, not whole-dataset validation.
- Some later sections repeat imports and setup because the notebook combines workstreams.
- The notebook's prose identifies named collaborators; preserve this context in the public portfolio.

## Recommended presentation

Keep the original notebook as historical evidence. Present a separate, **read-only**, clearly labelled technical excerpt for recruiters, with cloud resource names configurable and no automatic table writes.

## Next validation steps

1. Scan saved outputs and other notebooks for sensitive content.
2. Review authorship of individual components with the owner before claiming specific cells.
3. Test the read-only excerpt in a configured BigQuery environment (or state that it is untested).
4. If preparing a fully reproducible demo, use small licensed sample data rather than private cloud resources.
