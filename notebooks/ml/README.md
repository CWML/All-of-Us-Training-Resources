# Machine learning series (7.x)

Classes on **prediction**, using the same type 2 diabetes cohort as the other series. The question in every class:
from data collected **before** a diagnosis, who will be diagnosed with type 2 diabetes in the next few years?

| Notebook | What it does |
|---|---|
| **ml_data_check** | A planning notebook, not a class: who has each kind of data, when it was collected, and how many developed type 2 diabetes afterwards. It set the designs below |
| **7.1 first_prediction_model** | Enrollment data (age, sex, BMI, blood pressure, survey answers) predicting new type 2 diabetes within 2 years; training and test sets; logistic regression with tidymodels; AUC, ROC curve, calibration; LASSO with cross-validation. Saves `ml_t2d_2yr.csv` |
| **7.2 trees_and_boosting** | Random forests (ranger) and gradient boosting (xgboost, tuned) on the 7.1 data and split; AUC, Brier score, calibration; permutation importance; partial dependence. Reads `ml_t2d_2yr.csv` |
| **7.2b trees_in_python** | The same in Python with scikit-learn (Python 3 kernel): logistic regression and `HistGradientBoostingClassifier`, `GridSearchCV`, calibration, permutation importance |
| **7.3 protein_signature** | Olink proteins for people in 7.1's file; time zero = the later of enrollment and the blood draw; clinical vs proteins vs both, by nested cross-validation (glmnet); bootstrap CI for the AUC gain; the panel and its stability. Reads `ml_t2d_2yr.csv` |
| **7.4 combining_data_responsibly** | 7.1's model audited by group (AUC with bootstrap CI, observed/expected, cases reached by the top 10%); who's left with Fitbit and proteomics; enrollment data vs + Fitbit steps by cross-validation; TRIPOD+AI. Reads `ml_t2d_2yr.csv` |

Each notebook loads `../aou_setup.R`. The R modelling packages (tidymodels, glmnet, ranger, xgboost) are installed the first time
by `install_if_missing()`, which can take up to 15 minutes.

**Time zero** is enrollment: the date of each person's first survey. Only data from around that date are used
as predictors, and people already diagnosed by then are left out. See `notebooks/CURRICULUM_PLAN.md`, *Data check results*.
