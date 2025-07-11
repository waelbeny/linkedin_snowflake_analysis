# linkedin_snowflake_analysis

# 🧊 Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake

## 🎓 Contexte
Ce projet est réalisé dans le cadre du MBA Big Data & Intelligence Artificielle à MBA ESG.  
L’objectif est de démontrer notre capacité à manipuler, transformer et analyser un large jeu de données métier sur le marché de l'emploi via la plateforme **Snowflake**, en exploitant SQL et Streamlit pour créer des visualisations interactives.

---

## 📁 Données Utilisées

Les données sont issues d’un bucket public S3 :  
`s3://snowflake-lab-bucket/`

Fichiers utilisés :
- `job_postings.csv`
- `companies.json`
- `benefits.csv`
- `employee_counts.csv`
- `company_industries.json`
- `company_specialities.json`
- `job_industries.json`
- `job_skills.csv`

---

## 🧱 Préparation & Transformation

### 🧾 Étapes réalisées :
1. Création d’une base `linkedin` et d’un `STAGE` Snowflake.
2. Définition de deux `FILE FORMAT` (CSV et JSON).
3. Création des tables cibles selon les schémas fournis.
4. Chargement des données à l’aide de `COPY INTO`.
5. Extraction manuelle des données JSON à l’aide de colonnes `VARIANT` et de `SELECT` avec cast.
6. Jointures entre les différentes tables pour enrichissement des analyses.

---

## 📊 Analyses Réalisées

### ✅ Streamlit Apps créées dans Snowflake :

| Application | Description |
|------------|-------------|
| **APP_TOP10_TITLES** | Top 10 des titres de postes les plus publiés |
| **app_offres_par_experience** | Répartition des offres par niveau d’expérience |
| **app_offres_par_type** | Répartition des offres par type d’emploi (temps plein, partiel, etc.) |

---

## 🧪 Requêtes SQL Principales

```sql
-- Exemple : Top 10 des postes
SELECT title, COUNT(*) AS nb_postes
FROM job_postings
GROUP BY title
ORDER BY nb_postes DESC
LIMIT 10;
