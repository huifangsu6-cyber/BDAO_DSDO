# SQL and data-quality review notes

This is a **static review** of selected files already in the repository. It is not a cloud execution, a comprehensive security audit, or a claim that the data passed all checks.

## Existing SQL examples inspected

- [`sql/q7_peak_hours.sql`](../sql/q7_peak_hours.sql): BigQuery CTEs, timestamp extraction, grouped counts and a ranking window function.
- [`sql/q8_peak_windows.sql`](../sql/q8_peak_windows.sql): peak-window ranking and top-20 filtering.
- [`sql/q4_feature_boost.sql`](../sql/q4_feature_boost.sql): normalises boolean-like fields, constructs comparison cohorts and reports differences in mean star ratings.

### Interpretation caveats

1. **Check-ins are not unique customers or visits.** Counts describe records in the transformed Yelp check-in table; avoid describing them as measured footfall.
2. **Day/hour are extracted from the stored timestamp.** Interpretation as local restaurant opening hours depends on the source timestamp's timezone convention; the SQL alone does not establish local-time alignment.
3. **“Estimated star boost” is an observational difference.** The label in `q4_feature_boost.sql` is not a causal estimate. Restaurant type, geography, price and other factors may confound the comparison.
4. **Duplicates require a business definition.** Repeated `business_id` + `checkin_timestamp` pairs can be flagged for inspection, but should not be automatically deleted without understanding source semantics.

## Additional read-only example

[`portfolio/sql/checkin_quality_profile.sql`](sql/checkin_quality_profile.sql) provides a compact BigQuery data-quality profile: total rows, missing IDs/timestamps, distinct businesses, timestamp range and repeated business/timestamp combinations.

This example was **added during portfolio documentation**, based on the table and field names in the existing SQL. It is **not** represented as an original project deliverable, and its output has not been executed or verified.

## Before sharing the repository with recruiters

- Review all notebook cells and saved outputs for credentials, service-account JSON, API tokens, email addresses, private data and accidental exports.
- Ensure every screenshot or chart is legible without cloud access.
- If claiming reproducibility, supply data access instructions, dependencies and anonymised sample data; otherwise describe cloud dependencies accurately.
- Keep coursework teaching notebooks separate from the project's main authored workflow in the navigation.

No existing project code was rewritten as part of this review.
