-- =============================================================================
-- t2d_cohort.sql: the type 2 diabetes cohort, shared by every notebook
--
-- Returns ONE ROW PER PARTICIPANT who
--   * has electronic health record (EHR) data, and
--   * was 18 or older on the age reference date (or at death, if earlier),
-- with their demographics, the dates of their first and last EHR visit, death
-- information, three diabetes flags, the first type 2 diabetes date, and the
-- number of days with a type 2 diabetes code. The last column, `cohort`,
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

-- People with at least one EHR visit, and the dates of their first and last one.
-- `src_id` says where each visit came from:
--   'EHR site ...'               records sent by a hospital or clinic
--   'Participant Mediated EHR...' records the participant shared themselves
--   'Staff Portal' / 'Participant Portal'  program visits (physical measurements,
--                                surveys): these are NOT health records, so they
--                                don't count
-- The first and last EHR dates show when we could have seen a diagnosis:
-- they're used as the start and end of follow-up in the survival analysis.
ehr_people AS (
  SELECT
    v.person_id,
    MIN(v.visit_start_date) AS first_ehr_date,
    MAX(v.visit_start_date) AS last_ehr_date
  FROM `{CURRENT_DATASET}.visit_occurrence` AS v
  JOIN `{CURRENT_DATASET}.visit_occurrence_ext` AS ve
    ON v.visit_occurrence_id = ve.visit_occurrence_id
  WHERE STARTS_WITH(ve.src_id, 'EHR site')
     OR STARTS_WITH(ve.src_id, 'Participant Mediated EHR')
  GROUP BY v.person_id
),

-- Date of death, for people who have died. MIN() keeps one date per person,
-- in case there is more than one record. If only the year of death is known,
-- the date is recorded as December 31 of that year.
deaths AS (
  SELECT person_id, MIN(death_date) AS death_date
  FROM `{CURRENT_DATASET}.death`
  GROUP BY person_id
),

-- People with a type 2 diabetes diagnosis (201826 or anything below it), with
--   first_t2d_date  the first date a type 2 diabetes code appears (the start of
--                   follow-up in the survival analysis)
--   t2d_code_days   how many DIFFERENT days a type 2 diabetes code appears. Our
--                   case definition needs 1; a stricter definition (used by
--                   All by All) needs 2 or more. Counting days, not codes, so
--                   several codes on the same visit count once.
t2d AS (
  SELECT
    co.person_id,
    MIN(co.condition_start_date)            AS first_t2d_date,
    COUNT(DISTINCT co.condition_start_date) AS t2d_code_days
  FROM `{CURRENT_DATASET}.condition_occurrence` AS co
  JOIN `{CURRENT_DATASET}.concept_ancestor` AS ca
    ON co.condition_concept_id = ca.descendant_concept_id
  WHERE ca.ancestor_concept_id = 201826
  GROUP BY co.person_id
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

-- Demographics for everyone with EHR data.
-- `age_on` is the date we calculate age on: the age date, or the date of death
-- if that came first (otherwise a person who died in 2019 would keep "getting older").
people AS (
  SELECT
    p.person_id,
    DATE(p.birth_datetime) AS date_of_birth,
    LEAST(DATE '{AGE_DATE}', COALESCE(d.death_date, DATE '{AGE_DATE}')) AS age_on,
    d.death_date IS NOT NULL AS deceased,
    d.death_date,
    e.first_ehr_date,
    e.last_ehr_date,
    sex.concept_name      AS sex_at_birth,
    gender.concept_name   AS gender,
    race.concept_name     AS race,
    ethnicity.concept_name AS ethnicity,
    category.concept_name AS self_reported_category
  FROM `{CURRENT_DATASET}.person` AS p
  JOIN ehr_people AS e
    ON p.person_id = e.person_id
  LEFT JOIN deaths AS d
    ON p.person_id = d.person_id
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
),

-- Age in whole years on `age_on`: the difference in years, minus 1 if their
-- birthday hadn't come yet that year.
people_with_age AS (
  SELECT
    *,
    DATE_DIFF(age_on, date_of_birth, YEAR)
      - IF(FORMAT_DATE('%m%d', date_of_birth) > FORMAT_DATE('%m%d', age_on), 1, 0) AS age
  FROM people
)

SELECT
  people.*,
  t2d.first_t2d_date,
  COALESCE(t2d.t2d_code_days, 0)                           AS t2d_code_days,
  people.person_id IN (SELECT person_id FROM t2d)          AS has_t2d,
  people.person_id IN (SELECT person_id FROM t1d)          AS has_t1d,
  people.person_id IN (SELECT person_id FROM any_diabetes) AS has_any_diabetes,
  CASE
    WHEN people.person_id IN (SELECT person_id FROM t2d)
     AND people.person_id NOT IN (SELECT person_id FROM t1d)          THEN 'case'
    WHEN people.person_id NOT IN (SELECT person_id FROM any_diabetes) THEN 'control'
    ELSE 'excluded'
  END AS cohort
FROM people_with_age AS people
LEFT JOIN t2d
  ON people.person_id = t2d.person_id
WHERE people.age >= 18
