# Survey series (5.x)

Classes on the *All of Us* survey data, using the same type 2 diabetes cohort as the other series. Companion pages: https://cwml.github.io/All-of-Us-Training-Resources/pages/courses/surveys/

| Class | What it does |
|---|---|
| **5.1 survey_basics** | The ten surveys and who answered them; a question dictionary; non-answers (*PMI: Skip*, *Prefer Not To Answer*, ...); skip logic; select-all questions; one row per person |
| **5.2 family_history_lifestyle** | Family history (a select-all question), smoking, and alcohol; denominators; self-report vs records; reverse causation; sensitivity analyses |
| **5.3 social_factors** | *(in progress)* Income, education, food security, health care access, and type 2 diabetes |

Each notebook loads `../aou_setup.R`. They use `cohort_sample.csv` from **1.1**; `load_cohort_sample()` makes it if it's missing.
