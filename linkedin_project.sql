-- 🧊 1. CRÉATION DE LA BASE DE DONNÉES ET UTILISATION DU SCHÉMA PUBLIC
CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;
USE SCHEMA PUBLIC;

-- 🗂️ 2. DÉFINITION DES FORMATS DE FICHIERS

-- Format CSV avec entête et délimiteurs standards
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1;

-- Format JSON
CREATE OR REPLACE FILE FORMAT json_format
  TYPE = 'JSON';

-- 📦 3. STAGE EXTERNE POINTANT VERS LE BUCKET S3
CREATE OR REPLACE STAGE linkedin_stage
  URL = 's3://snowflake-lab-bucket/'
  FILE_FORMAT = csv_format;

-- ⏬ Lister les fichiers du stage pour contrôle
LIST @linkedin_stage;

-- 🏗️ 4. CRÉATION DES TABLES PRINCIPALES

CREATE OR REPLACE TABLE job_postings (
  job_id STRING,
  company_id STRING,
  title STRING,
  description STRING,
  max_salary FLOAT,
  med_salary FLOAT,
  min_salary FLOAT,
  pay_period STRING,
  formatted_work_type STRING,
  location STRING,
  applies INT,
  original_listed_time FLOAT,
  remote_allowed BOOLEAN,
  views INT,
  job_posting_url STRING,
  application_url STRING,
  application_type STRING,
  expiry FLOAT,
  closed_time FLOAT,
  formatted_experience_level STRING,
  skills_desc STRING,
  listed_time FLOAT,
  posting_domain STRING,
  sponsored BOOLEAN,
  work_type STRING,
  currency STRING,
  compensation_type STRING
);

CREATE OR REPLACE TABLE benefits (
  job_id STRING,
  inferred BOOLEAN,
  type STRING
);

CREATE OR REPLACE TABLE companies (
  company_id STRING,
  name STRING,
  description STRING,
  company_size INT,
  state STRING,
  country STRING,
  city STRING,
  zip_code STRING,
  address STRING,
  url STRING
);

CREATE OR REPLACE TABLE employee_counts (
  company_id STRING,
  employee_count INT,
  follower_count INT,
  time_recorded FLOAT
);

-- 🧪 5. FICHIERS JSON À DÉCOMPOSER

-- 💼 company_specialities.json
CREATE OR REPLACE TABLE company_specialities_raw (data VARIANT);

COPY INTO company_specialities_raw
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = json_format;

CREATE OR REPLACE TABLE company_specialities (
  company_id STRING,
  speciality STRING
);

INSERT INTO company_specialities
SELECT
  data:"company_id"::STRING,
  data:"speciality"::STRING
FROM company_specialities_raw;

-- 🏭 company_industries.json
CREATE OR REPLACE TABLE company_industries_raw (data VARIANT);

COPY INTO company_industries_raw
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = json_format;

CREATE OR REPLACE TABLE company_industries (
  company_id STRING,
  industry STRING
);

INSERT INTO company_industries
SELECT
  data:"company_id"::STRING,
  data:"industry"::STRING
FROM company_industries_raw;

-- 🧩 job_industries.json
CREATE OR REPLACE TABLE job_industries_raw (data VARIANT);

COPY INTO job_industries_raw
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = json_format;

CREATE OR REPLACE TABLE job_industries (
  job_id STRING,
  industry_id STRING
);

INSERT INTO job_industries
SELECT
  data:"job_id"::STRING,
  data:"industry_id"::STRING
FROM job_industries_raw;

-- 🧠 job_skills.json (optionnel si utilisé dans ton analyse)
CREATE OR REPLACE TABLE job_skills_raw (data VARIANT);

COPY INTO job_skills_raw
FROM @linkedin_stage/job_skills.csv
FILE_FORMAT = csv_format;

-- ✅ 6. CHARGEMENT DES FICHIERS CSV

COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
ON_ERROR = 'CONTINUE';

COPY INTO benefits
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = csv_format;

COPY INTO companies
FROM @linkedin_stage/companies.json
FILE_FORMAT = json_format
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO employee_counts
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = csv_format;

-- 🔍 7. ANALYSES DEMANDÉES

-- 📊 1. Top 10 titres de postes les plus publiés
SELECT title, COUNT(*) AS nb_postes
FROM job_postings
GROUP BY title
ORDER BY nb_postes DESC
LIMIT 10;

-- 📊 2. Top 10 des postes les mieux rémunérés par industrie
SELECT 
    jp.title,
    ji.industry_id,
    MAX(jp.max_salary) AS salaire_max
FROM job_postings jp
JOIN job_industries ji ON jp.job_id = ji.job_id
WHERE jp.max_salary IS NOT NULL
GROUP BY jp.title, ji.industry_id
ORDER BY salaire_max DESC
LIMIT 10;

-- 📊 3. Répartition des offres par type d'emploi
SELECT formatted_work_type, COUNT(*) AS nb_offres
FROM job_postings
GROUP BY formatted_work_type
ORDER BY nb_offres DESC;

-- 📊 4. Répartition par taille d’entreprise
SELECT 
  c.company_size,
  COUNT(*) AS nb_offres
FROM job_postings jp
JOIN companies c ON jp.company_id = c.company_id
GROUP BY c.company_size
ORDER BY nb_offres DESC;

-- 📊 5. Répartition par secteur d’activité (industry)
SELECT
  ci.industry,
  COUNT(*) AS nb
FROM job_postings jp
JOIN company_industries ci ON jp.company_id = ci.company_id
GROUP BY ci.industry
ORDER BY nb DESC;

-- ✅ Contrôles finaux
SELECT COUNT(*) FROM job_postings;
SELECT COUNT(*) FROM job_industries;
SELECT COUNT(*) FROM benefits;
SELECT COUNT(*) FROM companies;
