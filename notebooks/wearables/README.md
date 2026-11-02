# Wearables series (6.x)

Classes on the *All of Us* wearable data, using the same type 2 diabetes cohort as the other series:
**Fitbit** (in the main CDR v9 dataset) and **Apple HealthKit** (a separate, off-cycle CDR v9 dataset,
`C_V9_R6_offcycle_healthkit`, joined by `person_id`).

| Class | What it does |
|---|---|
| **6.1 wearables_basics** | Fitbit and HealthKit tables and their cost (the minute-level tables are over 6 TB, clustered by `person_id`); valid wear days; one value per person; Fitbit vs iPhone vs Apple Watch steps; who has wearable data |
| **6.2 steps_and_t2d** | *(planned)* Daily steps and type 2 diabetes, using steps measured before a diagnosis |
| **6.3 sleep_and_heart_rate** | *(planned)* Sleep and heart rate; optional: HealthKit blood glucose |

Each notebook loads `../aou_setup.R`, which has two cost helpers for this series: `run_if_cheap()` (a free dry
run before every query) and `last_query_cost()` (what a query actually billed).
