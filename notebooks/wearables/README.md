# Wearables series (6.x)

Classes on the *All of Us* wearable data, using the same type 2 diabetes cohort as the other series:
**Fitbit** (in the main CDR v9 dataset) and **Apple HealthKit** (a separate, off-cycle CDR v9 dataset,
`C_V9_R6_offcycle_healthkit`, joined by `person_id`).

| Class | What it does |
|---|---|
| **6.1 wearables_basics** | Fitbit and HealthKit tables and their cost (the minute-level tables are over 6 TB, clustered by `person_id`); valid wear days and a check of the wear measure; one value per person; Fitbit vs iPhone vs Apple Watch steps; who has wearable data |
| **6.2 steps_and_t2d** | All Fitbit users followed forward: baseline steps (first 6 months), then new type 2 diabetes; flow table, incidence rates, Kaplan–Meier, Cox models with and without BMI, a 1-year lag |
| **6.3 sleep_and_heart_rate** | The 6.2 design as a function: Fitbit sleep (mainly a short-sleep link) and Apple HealthKit resting heart rate, then new type 2 diabetes; a first look at HealthKit blood glucose (selection by the outcome) |

Each notebook loads `../aou_setup.R`, which has two cost helpers for this series: `run_if_cheap()` (a free dry
run before every query) and `last_query_cost()` (what a query actually billed).
