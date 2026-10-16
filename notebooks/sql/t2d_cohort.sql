-- =============================================================================
-- t2d_cohort.sql: the type 2 diabetes cohort, shared by every notebook
--
-- Returns ONE ROW PER PARTICIPANT who
--   * has electronic health record (EHR) data, and
--   * was 18 or older on the age reference date,
-- with their demographics and three diabetes flags. The last column, `cohort`,
-- puts each person in one group:
--   case      type 2 diabetes, and no type 1 diabetes diagnosis
--   control   no diabetes diagnosis of any type
--   excluded  everyone else (e.g. type 1, or both type 1 and type 2)
--
-- The notebooks fill in these two placeholders before running it:
--   {CURRENT_DATASET}  the dataset, e.g. wb-silky-artichoke-2408.C2025Q4R6
--   {AGE_DATE}         the date age is calculated on, e.g. 2025-01-01
--
-- Concept IDs (check them at https://athena.ohdsi.org):
--   201826  Type 2 diabetes mellitus
--   201254  Type 1 diabetes mellitus
--   201820  Diabetes mellitus (all types)
-- `concept_ancestor` links each of these to every more specific concept below
-- it (e.g. "Type 2 diabetes mellitus with diabetic nephropathy"), and to itself.
-- =============================================================================

WITH

-- People with at least one visit recorded by an EHR site (hospital or clinic).
-- Visits from the program itself (surveys, physical measurements) don't count.
ehr_people AS (
  SELECT DISTINCT v.person_id
  FROM `{CURRENT_DATASET}.visit_occurrence` AS v
  JOIN `{CURRENT_DATASET}.visit_occurrence_ext` AS ve
    ON v.visit_occurrence_id = ve.visit_occurrence_id
  WHERE ve.src_id LIKE 'EHR site%'
),

-- People with a type 2 diabetes diagnosis (201826 or anything below it)
t2d AS (
  SELECT DISTINCT co.person_id
  FROM `{CURRENT_DATASET}.condition_occurrence` AS co
  JOIN `{CURRENT_DATASET}.concept_ancestor` AS ca
    ON co.condition_concept_id = ca.descendant_concept_id
  WHERE ca.ancestor_concept_id = 201826
),

-- People with a type 1 diabetes diagnosis (201254 or anything below it)
t1d AS (
  SELECT DISTINCT co.person_id
  FROM `{CURRENT_DATASET}.condition_occurrence` AS co
  JOIN `{CURRENT_DATASET}.concept_ancestor` AS ca
    ON co.condition_concept_id = ca.descendant_concept_id
  WHERE ca.ancestor_concept_id = 201254
),

-- People with a diagnosis of diabetes of ANY type (201820 or anything below it)
any_diabetes AS (
  SELECT DISTINCT co.person_id
  FROM `{CURRENT_DATASET}.condition_occurrence` AS co
  JOIN `{CURRENT_DATASET}.concept_ancestor` AS ca
    ON co.condition_concept_id = ca.descendant_concept_id
  WHERE ca.ancestor_concept_id = 201820
),

-- Demographics for everyone with EHR data, with age on the reference date.
-- Age = the difference in years, minus 1 if their birthday hadn't come yet that year.
people AS (
  SELECT
    p.person_id,
    DATE(p.birth_datetime) AS date_of_birth,
    DATE_DIFF(DATE '{AGE_DATE}', DATE(p.birth_datetime), YEAR)
      - IF(FORMAT_DATE('%m%d', DATE(p.birth_datetime)) > FORMAT_DATE('%m%d', DATE '{AGE_DATE}'), 1, 0)
      AS age,
    sex.concept_name      AS sex_at_birth,
    gender.concept_name   AS gender,
    race.concept_name     AS race,
    ethnicity.concept_name AS ethnicity,
    category.concept_name AS self_reported_category
  FROM `{CURRENT_DATASET}.person` AS p
  JOIN ehr_people AS e
    ON p.person_id = e.person_id
  LEFT JOIN `{CURRENT_DATASET}.concept` AS sex
    ON p.sex_at_birth_concept_id = sex.concept_id
  LEFT JOIN `{CURRENT_DATASET}.concept` AS gender
    ON p.gender_concept_id = gender.concept_id
  LEFT JOIN `{CURRENT_DATASET}.concept` AS race
    ON p.race_concept_id = race.concept_id
  LEFT JOIN `{CURRENT_DATASET}.concept` AS ethnicity
    ON p.ethnicity_concept_id = ethnicity.concept_id
  LEFT JOIN `{CURRENT_DATASET}.concept` AS category
    ON p.self_reported_category_concept_id = category.concept_id
)

SELECT
  people.*,
  people.person_id IN (SELECT person_id FROM t2d)          AS has_t2d,
  people.person_id IN (SELECT person_id FROM t1d)          AS has_t1d,
  people.person_id IN (SELECT person_id FROM any_diabetes) AS has_any_diabetes,
  CASE
    WHEN people.person_id IN (SELECT person_id FROM t2d)
     AND people.person_id NOT IN (SELECT person_id FROM t1d)          THEN 'case'
    WHEN people.person_id NOT IN (SELECT person_id FROM any_diabetes) THEN 'control'
    ELSE 'excluded'
  END AS cohort
FROM people
WHERE people.age >= 18
