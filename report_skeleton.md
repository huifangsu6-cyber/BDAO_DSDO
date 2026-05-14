# NROA Restaurant Success Index — Report Skeleton

**Project:** BDAO Group Project — Yelp Restaurant Success Index  
**Client frame:** National Restaurant Owners Association (NROA)  
**Chapter focus:** Performance and Customer Voice  
**Purpose of this skeleton:** Provide a clear report routine showing how the team moved from assignment requirements → business questions → BigQuery SQL/Python analysis → CSV outputs → figures → report findings and recommendations.

---

## 0. How to use this skeleton

Use this file as the structure for the final written report or presentation script. The aim is not only to present results, but to make the analysis routine transparent:

1. **Question:** What business question are we answering?
2. **Initial finding:** What did earlier analysis suggest?
3. **Method:** What table, SQL/Python logic, and comparison did we use?
4. **Evidence:** Which SQL file, notebook, CSV output, and figure support the claim?
5. **Interpretation:** What does the result mean for NROA members?
6. **Recommendation:** What should owners do or avoid doing?
7. **Limitation:** What should we not overclaim?

---

## 1. Executive summary skeleton

### 1.1 Client problem

NROA represents independent restaurant owners who often do not have internal analytics teams. The Restaurant Success Index is designed to translate Yelp data into practical benchmarks that owners can act on.

### 1.2 Core research question

**Which restaurant features, pricing patterns, demand windows, market conditions, and customer complaints are associated with restaurant success or failure?**

### 1.3 Overall story

Our analysis followed three layers:

1. **Internal success features:** What do high-rated/open restaurants have?  
   Covered by Q1, Q2, Q4, Q5, Q6.
2. **Customer voice and operations:** What do customers complain about, and when does demand pressure occur?  
   Covered by Q3, Q7, Q8, Q10, Q11.
3. **Market context:** How does city/category competition affect interpretation?  
   Covered by Q9.

### 1.4 Headline recommendations to refine

- Do **not** give one-size-fits-all recommendations.
- Prioritise visible success features, but interpret them by restaurant type, city, and operating model.
- Treat pricing, opening hours, TVs, and competition as **context variables**, not simple causal levers.
- Use review/tip complaint keywords to monitor operational failures, especially wait time, orders, manager escalation, cold food, rude service, and slow service.

---

## 2. Project routine / analysis pipeline

### 2.1 Data source routine

The project uses Yelp data already loaded to BigQuery under:

- `bdao-group-yelp.yelp_dataset.yelp_restaurants`
- `bdao-group-yelp.yelp_dataset.yelp_reviews`
- `bdao-group-yelp.yelp_dataset.yelp_tips`
- `bdao-group-yelp.yelp_dataset.yelp_checkin_clean`

### 2.2 Analysis routine

| Stage | What we did | Evidence file |
|---|---|---|
| 1. Define business question | Converted the NROA goal into Q1–Q11 business questions | `BDAO GA DP D1.docx`, `NROA_Restaurant_Success_Index_Report_1.docx` |
| 2. Validate/prepare data | Used team notebooks to inspect reviews, restaurants, check-ins, tips, users | `BDAO_group_project_yelp-3.ipynb` |
| 3. Run SQL/Python | Wrote one focused query or notebook per question | `sql/`, `q8_opening_hours_alignment.ipynb` |
| 4. Export results | Saved BigQuery/Python outputs as CSV files | `outputs/tables/` |
| 5. Visualise | Read CSV files only; did not rerun BigQuery | `final_visualisations.ipynb`, `final_visualisations.py` |
| 6. Interpret | Connected each figure back to business decisions | This report skeleton |

### 2.3 Final visualisation routine

The final visualisation notebook/script should only read saved CSV files and save PNGs. It should not rerun BigQuery.

- Notebook: `final_visualisations.ipynb`
- Script: `final_visualisations.py`
- CSV input folder: `outputs/tables/`
- Figure output folder: `outputs/figures/`

---

## 3. Evidence map: questions, code, CSVs, and figures

| Q | Business question | Main method | Code evidence | CSV evidence | Figure evidence | Report status |
|---|---|---|---|---|---|---|
| Q1 | Which features separate high-rated/open restaurants from low-rated restaurants? | Attribute gap comparison | `huifang_yelp_summary_analysis-2.ipynb` | Add/export if needed | Existing notebook chart / report figure | Core finding |
| Q2 | Which feature matters most for prioritisation? | Random Forest feature importance + price deep dive | `huifang_yelp_summary_analysis-2.ipynb` | Add/export if needed | Existing notebook chart / report figure | Core finding |
| Q3 | What do customers at high-rated vs low-rated restaurants say? | Review keyword / text analysis | `huifang_yelp_summary_analysis-2.ipynb` | Add/export if needed | Existing notebook chart / report figure | Core finding |
| Q4 | If owners can afford only one success feature, which gives biggest rating boost? | Single-feature comparison vs no-feature baseline | `sql/q4_feature_boost.sql` | `outputs/tables/q4_feature_boost_results.csv` | `outputs/figures/q4_feature_boost.png` | Completed |
| Q5 | Is HasTV truly bad, or a category/type confounder? | HasTV vs NoTV within category | `sql/q5_has_tv_by_category.sql` | `outputs/tables/q5_has_tv_results.csv` | `outputs/figures/q5_has_tv_gap.png` | Completed |
| Q6 | Does price-tier advice hold across major cities? | City × price tier comparison | `sql/q6_price_by_city.sql` | `outputs/tables/q6_price_by_city_results.csv.csv` | `outputs/figures/q6_price_by_city.png` | Completed |
| Q7 | When are restaurants busiest? | Check-in count by day/hour | `sql/q7_peak_hours.sql` | `outputs/tables/q7_peak_hours_results.csv.csv` | `outputs/figures/q7_peak_hours_heatmap.png` | Completed |
| Q8 | Are restaurants open when customers want to visit? | SQL peak windows + Python hours parsing | `sql/q8_peak_windows.sql`, `sql/q8_restaurant_hours_export.sql`, `q8_opening_hours_alignment.ipynb` | `outputs/tables/q8_opening_hours_alignment_results.csv` | `outputs/figures/q8_peak_coverage_rating.png` | Completed |
| Q9 | Where is competition fiercest, and do restaurants rate worse there? | City and city-category density analysis | `sql/q9_competition_density.sql` | `outputs/tables/q9_competition_density_results.csv` | `outputs/figures/q9_density_vs_rating.png` | Completed / ensure CSV is saved |
| Q10 | Do tips flag same operational problems as full reviews? | Keyword rate per 10,000 text records | `sql/q10_tips_reviews_keywords.sql` | `outputs/tables/q10_tips_reviews_keywords_results.csv` | `outputs/figures/q10_tips_reviews_keywords.png` | Completed |
| Q11 | Which strong-on-paper restaurants still fail, and what do customers complain about? | Feature-score cohort + review keyword baseline | `sql/q11_failing_winners.sql` | `outputs/tables/q11_failing_winners_results.csv.csv` | `outputs/figures/q11_failing_strong_keywords.png` | Completed |

---

## 4. Detailed question-by-question report skeleton

## Q1 — Which features separate high-rated/open restaurants from low-rated restaurants?

### Business purpose

NROA needs a concrete benchmark showing which restaurant profile features are most associated with success.

### Initial finding

Earlier analysis found that **OutdoorSeating**, **Caters**, and **RestaurantsReservations** were among the largest positive feature gaps between high-rated/open and low-rated restaurants.

### What we did

- Used `yelp_restaurants`.
- Split restaurants into high-rated/open and low-rated groups.
- Compared feature proportions between groups.
- Used this as the starting point for Q4, Q5, and Q6 robustness checks.

### Evidence to include

- Code: `huifang_yelp_summary_analysis-2.ipynb`
- Written report draft: `NROA_Restaurant_Success_Index_Report_1.docx`
- Figure: feature comparison bar chart from existing notebook/report.

### Report paragraph placeholder

> Q1 identifies the first layer of the Restaurant Success Index: which observable restaurant features differ most between stronger and weaker performers. The feature comparison suggests that outdoor seating, catering, and reservations are meaningful success signals. These features should not be treated as guaranteed causes of higher ratings, but they provide a practical benchmark for NROA members to compare against their own business profile.

### Recommendation placeholder

Owners should check whether their profile reflects relevant success features, but should only adopt features that fit their concept, city, climate, and operating model.

### Limitation

Feature gaps show association, not causation. Some features may proxy for restaurant type, service model, or customer expectations.

---

## Q2 — Which feature matters most, and what should owners prioritise first?

### Business purpose

Owners cannot improve everything at once. Q2 creates a priority ranking.

### Initial finding

Earlier analysis indicated that price tier was a strong predictor, with mid-range positioning often outperforming budget positioning.

### What we did

- Used `yelp_restaurants`.
- Built a model using restaurant attributes.
- Compared feature importance and interpreted it in business language.
- Used Q6 to check whether the price-tier recommendation holds across cities.

### Evidence to include

- Code: `huifang_yelp_summary_analysis-2.ipynb`
- Written report draft: `NROA_Restaurant_Success_Index_Report_1.docx`
- Follow-up robustness: `sql/q6_price_by_city.sql`

### Report paragraph placeholder

> Q2 moves from feature comparison to prioritisation. The model-based analysis suggests that not all restaurant attributes are equally informative. Price tier requires special care because it may reflect customer expectations, restaurant positioning, and perceived quality rather than price alone. Therefore, the recommendation should focus on pricing fit and value perception rather than simply telling all restaurants to increase prices.

### Recommendation placeholder

Budget-tier owners should examine whether their pricing matches their quality and service level, but should not raise prices without improving customer value perception.

### Limitation

A predictive model ranks useful signals but does not prove that changing a feature will cause ratings to rise.

---

## Q3 — What do customers at high-rated restaurants say that customers at low-rated restaurants do not?

### Business purpose

Structured features show what restaurants have; review text explains what customers experience.

### Initial finding

Earlier review analysis suggested that low-rated restaurants are associated with operational complaints such as orders, waits, minutes, managers, rude service, wrong items, slow service, and cold food.

### What we did

- Joined `yelp_reviews` to `yelp_restaurants`.
- Compared high-rated/open restaurant review language with low-rated restaurant review language.
- Used the complaint keyword set again in Q10 and Q11.

### Evidence to include

- Code: `huifang_yelp_summary_analysis-2.ipynb`
- Follow-up SQL: `sql/q10_tips_reviews_keywords.sql`, `sql/q11_failing_winners.sql`

### Report paragraph placeholder

> Q3 adds customer voice to the structured feature analysis. While Q1 and Q2 identify visible success signals, Q3 shows that poor ratings are often explained through operational failures. Customers at struggling restaurants are not only judging food or amenities; they are reacting to slow service, waiting, order mistakes, manager escalation, cold food, and rude interactions.

### Recommendation placeholder

Owners should monitor recent reviews for operational failure words and treat repeated mentions as process problems rather than isolated complaints.

### Limitation

Keyword analysis is transparent and useful for reporting, but it does not capture every nuance of sentiment or topic meaning.

---

## Q4 — If an owner can only afford one success feature, which should come first?

### Business purpose

Q4 turns the Q1 feature set into a budget-constrained recommendation.

### What we did

- Used `yelp_restaurants`.
- Compared restaurants with only one of the three winning features against restaurants with none of the three.
- Features tested: `OutdoorSeating`, `Caters`, `RestaurantsReservations`.

### Result summary from CSV

| Feature option | Restaurants | Avg stars | Baseline avg stars | Estimated boost |
|---|---:|---:|---:|---:|
| RestaurantsReservations only | 1,064 | 3.612 | 3.088 | +0.523 |
| Caters only | 3,707 | 3.499 | 3.088 | +0.411 |
| OutdoorSeating only | 2,395 | 3.478 | 3.088 | +0.390 |

### Evidence

- SQL: `sql/q4_feature_boost.sql`
- CSV: `outputs/tables/q4_feature_boost_results.csv`
- Figure: `outputs/figures/q4_feature_boost.png`

### Report paragraph placeholder

> Q4 shows that all three Q1 success features remain positively associated with ratings when tested as single-feature options against a no-feature baseline. Reservations show the largest single-feature rating difference in this comparison, followed by catering and outdoor seating. This supports the original Q1 finding but adds a clearer priority order for owners who can only act on one improvement.

### Recommendation

If the restaurant format supports bookings, reservations should be considered a high-priority low-complexity improvement. However, reservations may also signal a more organised full-service model, so this should not be framed as causal proof.

### Limitation

The single-feature groups may differ by restaurant type, service model, and customer expectations.

---

## Q5 — Should restaurants with TVs remove them?

### Business purpose

Q5 prevents a bad recommendation. Earlier results suggested HasTV restaurants rate lower overall, but that may reflect restaurant type rather than TVs themselves.

### What we did

- Used `yelp_restaurants`.
- Split `categories` using `UNNEST(SPLIT(categories, ','))`.
- Compared HasTV vs NoTV within each category.
- Kept categories with enough restaurants in both groups.

### Result summary from CSV

The largest negative gaps include categories such as Tacos, Coffee & Tea, Tex-Mex, Hotels & Travel, and Hot Dogs. For example, Tacos shows a HasTV average of 3.030 vs NoTV average of 4.230, a gap of -1.200.

### Evidence

- SQL: `sql/q5_has_tv_by_category.sql`
- CSV: `outputs/tables/q5_has_tv_results.csv`
- Figure: `outputs/figures/q5_has_tv_gap.png`

### Report paragraph placeholder

> Q5 shows why the HasTV result should be interpreted as a context variable rather than a direct action lever. The rating gap varies by category, meaning HasTV is likely connected to restaurant type, atmosphere, service model, and customer expectations. NROA should not tell sports bars or casual venues to remove TVs. Instead, TV-heavy venues should manage noise, layout, atmosphere, and service quality carefully.

### Recommendation

Do not make “remove TVs” a Restaurant Success Index recommendation. Use HasTV as a diagnostic/context flag.

### Limitation

Category labels are multi-value and imperfect. A restaurant can appear in several category groups.

---

## Q6 — Does price-tier advice hold across major US cities?

### Business purpose

Q6 tests whether the Q2 price-tier recommendation is robust across cities.

### What we did

- Used `yelp_restaurants`.
- Compared average stars by price tier within top city markets.
- Focused especially on Budget vs Mid-range.

### Result summary from CSV

In Philadelphia, Mid-range restaurants average 3.632 stars versus 3.396 for Budget restaurants, a +0.236 gap. The CSV should be reviewed city by city to decide whether the pattern is broad or market-specific.

### Evidence

- SQL: `sql/q6_price_by_city.sql`
- CSV: `outputs/tables/q6_price_by_city_results.csv.csv`
- Figure: `outputs/figures/q6_price_by_city.png`

### Report paragraph placeholder

> Q6 stress-tests the pricing recommendation by city. The purpose is to avoid turning a dataset-wide pattern into an overgeneralised national claim. Where Mid-range outperforms Budget, pricing may reflect stronger positioning and customer value perception. Where the gap is weak or reversed, NROA should recommend local benchmarking rather than a universal pricing move.

### Recommendation

Owners should benchmark price tier against similar local competitors before repositioning.

### Limitation

Price tier may capture positioning, cuisine, service model, and customer expectations, not price alone.

---

## Q7 — When are restaurants busiest?

### Business purpose

Q7 identifies demand pressure windows for staffing, stock planning, service readiness, and promotion timing.

### What we did

- Used `yelp_checkin_clean`.
- Counted check-ins by day of week and hour.
- Created a heatmap and ranked busiest windows.

### Result summary from CSV

The busiest windows are concentrated around weekend evening and late-night periods. The top window is Sunday 00:00–00:59 with 166,963 check-ins and 1.961% of all check-ins.

### Evidence

- SQL: `sql/q7_peak_hours.sql`
- CSV: `outputs/tables/q7_peak_hours_results.csv.csv`
- Figure: `outputs/figures/q7_peak_hours_heatmap.png`

### Report paragraph placeholder

> Q7 shows that customer activity is not evenly distributed across the week. Check-ins concentrate around weekend evening and late-night windows, suggesting that restaurants face the strongest operational pressure during leisure periods. This finding provides the timing context for Q8 and helps interpret Q3 operational complaints.

### Recommendation

Owners should align staffing and preparation with demand peaks, not average demand.

### Limitation

Check-ins are a demand proxy and timestamps may not perfectly match each restaurant's local time zone.

---

## Q8 — Are restaurants open when customers want to visit?

### Business purpose

Q8 tests whether being open during Q7 peak demand windows is associated with better ratings.

### What we did

- Used `yelp_checkin_clean` to define top peak day-hour windows.
- Used `yelp_restaurants` to export `hours` data.
- Used Python to parse dictionary-style opening hours and handle overnight hours.
- Calculated each restaurant's peak coverage rate.

### Result summary from CSV

| Coverage group | Restaurants | Avg stars | % 4+ stars | Avg coverage |
|---|---:|---:|---:|---:|
| High coverage | 7,390 | 3.020 | 22.52% | 0.922 |
| Partial coverage | 32,902 | 3.599 | 48.52% | 0.441 |
| No coverage | 4,698 | 3.995 | 71.09% | 0.000 |

### Evidence

- SQL: `sql/q8_peak_windows.sql`, `sql/q8_restaurant_hours_export.sql`
- Python: `q8_opening_hours_alignment.ipynb`
- CSV: `outputs/tables/q8_opening_hours_alignment_results.csv`
- Figure: `outputs/figures/q8_peak_coverage_rating.png`

### Report paragraph placeholder

> Q8 does not support a simple “stay open during all peak windows” recommendation. High peak-hour coverage is associated with lower average ratings in this output, while no-coverage restaurants have the highest average rating. This suggests that late-night/weekend peak windows may create operational pressure. Being open is not enough; restaurants must have the staffing, kitchen capacity, and service control to handle peak demand.

### Recommendation

Do not tell all restaurants to extend hours. Instead, advise owners to match opening hours to their own demand only when operational capacity is ready.

### Limitation

Global peak windows may not match every city/cuisine. Late-night coverage may be linked to specific restaurant types such as bars, fast food, nightlife, or casual venues.

---

## Q9 — Where is competition fiercest?

### Business purpose

Q9 adds market context. It asks whether city/category density is linked to worse ratings.

### What we did

- Used `yelp_restaurants`.
- Used restaurant count as a proxy for competition density.
- Analysed both city markets and city-category markets.
- Split categories using `UNNEST(SPLIT(categories, ','))`.

### Result summary to insert

From the pasted Q9 result:

- Largest city market: Philadelphia, PA with 5,852 restaurants and 3.556 average stars.
- Other major city markets include Tampa, Indianapolis, Nashville, Tucson, New Orleans, Saint Louis, Reno, Boise, and Santa Barbara.
- Dense category markets include Philadelphia Food, Philadelphia Nightlife, Tampa Food, Philadelphia Bars, Philadelphia Sandwiches, and Philadelphia Pizza.
- Some dense categories rate low, especially Fast Food, Burgers, and Pizza in certain cities.

### Evidence

- SQL: `sql/q9_competition_density.sql`
- CSV: `outputs/tables/q9_competition_density_results.csv` **(ensure this file is saved locally/GitHub; it was discussed but may need upload if missing)**
- Figure: `outputs/figures/q9_density_vs_rating.png`

### Report paragraph placeholder

> Q9 shows that competition density alone does not explain rating performance. Large markets such as Philadelphia are not automatically the lowest-rated, and some dense markets such as New Orleans perform strongly. The category-level view is more informative: crowded fast food, burger, and pizza markets show weaker ratings in several cities. This suggests that owners should benchmark against similar local competitors, not only the overall city market.

### Recommendation

NROA should encourage local category benchmarking: compare restaurants within the same city, category, and price tier.

### Limitation

Restaurant count is only a proxy for competition. It does not account for distance, population, neighbourhood, tourism, footfall, rent, delivery competition, or chain ownership. City names may also need cleaning, such as Saint Louis vs St. Louis.

---

## Q10 — Do tips flag the same operational problems as full reviews?

### Business purpose

Q10 tests whether short tips can act as a faster early-warning channel for operational problems.

### What we did

- Used `yelp_tips`, `yelp_reviews`, and `yelp_restaurants`.
- Focused on the same Q3 operational keywords.
- Compared keyword frequency per 10,000 text records.

### Result summary from CSV

Reviews mention the target complaint keywords more often than tips. For example, `order` appears 234.8 times per 10,000 tips versus 1,495.27 times per 10,000 reviews. Tips still contain operational signals, but at lower frequency.

### Evidence

- SQL: `sql/q10_tips_reviews_keywords.sql`
- CSV: `outputs/tables/q10_tips_reviews_keywords_results.csv`
- Figure: `outputs/figures/q10_tips_reviews_keywords.png`

### Report paragraph placeholder

> Q10 shows that tips and reviews contain the same types of operational warning signals, but reviews contain them much more frequently. This means tips can be used as a lightweight early-warning channel, but they should not replace full review monitoring. Owners should monitor both sources, with reviews providing richer diagnostic detail.

### Recommendation

Use tips as a quick weekly scan, but use reviews for deeper service diagnosis.

### Limitation

Tips are shorter and may be used differently by Yelp users, so lower keyword frequency does not mean tips are unimportant.

---

## Q11 — Which strong-on-paper restaurants still fail?

### Business purpose

Q11 tests whether restaurants with success signals can still perform poorly or close, and what customers complain about.

### What we did

- Created a feature score using OutdoorSeating, Caters, Reservations, and PriceRange2 = 2 or 3.
- Defined strong-on-paper restaurants as feature score >= 3.
- Defined failing as stars < 3.5 or is_open = 0.
- Compared complaint keyword frequencies against the overall restaurant review baseline.

### Result summary from CSV

The failing-strong cohort contains 5,875 restaurants with 3.397 average stars. It includes 4,699 closed restaurants and 2,570 low-rated restaurants. Some complaint keywords over-index versus the overall baseline, including manager, minutes, cold, wrong, slow, and rude.

### Evidence

- SQL: `sql/q11_failing_winners.sql`
- CSV: `outputs/tables/q11_failing_winners_results.csv.csv`
- Figure: `outputs/figures/q11_failing_strong_keywords.png`

### Report paragraph placeholder

> Q11 confirms that success features do not guarantee success. A restaurant can look strong on paper but still perform poorly or close if execution fails. The failing-strong cohort over-indexes on several operational complaint keywords, especially manager-related and waiting/time-related terms. This supports the central recommendation that NROA should combine feature benchmarks with operational monitoring.

### Recommendation

Owners should not stop at adding visible features. They must monitor complaint signals and fix service breakdowns.

### Limitation

Closed restaurants may have failed for reasons not captured by Yelp reviews, such as rent, staffing costs, ownership changes, or external shocks.

---

## 5. Group work distribution skeleton

Use this table to show that the final analysis was built from group data validation and table ownership, not only one person's final SQL.

| Team member | Main table/task | What they checked or produced | How it supported the final report |
|---|---|---|---|
| Bhavya | Business question / CNVO framing | Defined NROA needs and linked analysis to 4Ps | Supported question design and report framing |
| Jing | `yelp_reviews` diagnostics | Checked review quality, missingness, star range, text fields | Supported Q3, Q10, Q11 text analysis |
| Yihe | `yelp_checkin_clean` | Cleaned/exploded check-in timestamps and validated join keys | Supported Q7 and Q8 demand-window analysis |
| Qinxin | `yelp_users` | Checked user activity and rating behaviour | Supported confidence in review-user context |
| Xuanying | `yelp_tips` | Validated tips sample/full table and time fields | Supported Q10 tips vs reviews analysis |
| Weiyi | Diagnostic visualisations | Created early data quality visuals | Supported data confidence and presentation |
| Lady | `yelp_restaurants` | Confirmed restaurant attributes and schema | Supported Q1, Q2, Q4, Q5, Q6, Q9, Q11 |
| Huifang | Direction 1 core analysis | Ran Q1–Q3 and later Q4–Q11 extensions | Connected features, text, operations, and recommendations |

---

## 6. Final recommendation structure

### Recommendation 1 — Use success features as benchmarks, not guarantees

Evidence: Q1, Q4, Q11  
Message: Features such as reservations, catering, outdoor seating, and mid-tier positioning are useful signals, but execution still matters.

### Recommendation 2 — Benchmark pricing locally

Evidence: Q2, Q6, Q9  
Message: Mid-range positioning may be linked to better ratings, but owners must compare against city/category competitors.

### Recommendation 3 — Do not make context-blind recommendations

Evidence: Q5, Q8, Q9  
Message: TVs, late opening hours, and competition density depend strongly on restaurant type and market context.

### Recommendation 4 — Monitor operational complaint keywords

Evidence: Q3, Q7, Q10, Q11  
Message: Owners should track wait/order/manager/rude/wrong/cold/slow signals, especially during peak demand windows.

---

## 7. Required figures checklist

| Figure | File | Inserted into report? | Notes |
|---|---|---|---|
| Q4 feature boost | `outputs/figures/q4_feature_boost.png` | [ ] | Single-feature priority |
| Q5 HasTV category gap | `outputs/figures/q5_has_tv_gap.png` | [ ] | Use to avoid bad recommendation |
| Q6 price by city | `outputs/figures/q6_price_by_city.png` | [ ] | City robustness |
| Q7 peak hours heatmap | `outputs/figures/q7_peak_hours_heatmap.png` | [ ] | Demand pressure timing |
| Q8 peak coverage rating | `outputs/figures/q8_peak_coverage_rating.png` | [ ] | Open-hours alignment |
| Q9 density vs rating | `outputs/figures/q9_density_vs_rating.png` | [ ] | Market context |
| Q10 tips vs reviews keywords | `outputs/figures/q10_tips_reviews_keywords.png` | [ ] | Early warning channel |
| Q11 failing-strong keywords | `outputs/figures/q11_failing_strong_keywords.png` | [ ] | Features are not enough |

---

## 8. Limitations section skeleton

Use these limitations in the final report:

1. **Association, not causation:** The analysis identifies patterns linked to ratings, but does not prove that changing one feature causes ratings to rise.
2. **Yelp data is not financial data:** The dataset does not include revenue, profit, rent, labour cost, or owner strategy.
3. **Check-ins are a demand proxy:** They do not represent full footfall.
4. **Time zone limitation:** Check-in timestamps may not perfectly reflect each restaurant's local time.
5. **Category labels are messy:** Yelp categories are multi-label and may mix restaurant types.
6. **City names may need cleaning:** Example: Saint Louis vs St. Louis.
7. **Hours data may be inconsistent:** Opening-hour fields can be missing, outdated, or formatted differently.
8. **Independent vs chain status is not explicit:** Competition analysis uses all Yelp restaurant records as a proxy for the market faced by independent restaurants.

---

## 9. Final report conclusion skeleton

> The Restaurant Success Index should be presented as a practical benchmarking tool rather than a deterministic recipe for success. The analysis shows that visible success features, price positioning, demand timing, customer complaints, and local competition all matter. However, the strongest overall message is that context and execution determine whether these features translate into better ratings. NROA should therefore advise members to benchmark their restaurant profile, compare against similar local competitors, monitor customer complaint keywords, and improve operational capacity before making major changes to pricing, opening hours, or service format.

