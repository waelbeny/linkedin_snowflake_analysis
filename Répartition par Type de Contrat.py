import streamlit as st
import pandas as pd
import snowflake.connector

st.set_page_config(page_title="Répartition par Type de Contrat", layout="centered")
st.title("📊 Répartition des offres d’emploi par type de contrat")

# 🔐 Connexion à Snowflake
conn = snowflake.connector.connect(
    user="TON_UTILISATEUR",
    password="TON_MOT_DE_PASSE",
    account="TON_COMPTE",      # ex: abcd-xy123.eu-west-1
    warehouse="TON_WAREHOUSE",
    database="linkedin",
    schema="public"
)

# 🧠 Requête SQL
query = """
SELECT formatted_work_type, COUNT(*) AS nb_offres
FROM job_postings
GROUP BY formatted_work_type
ORDER BY nb_offres DESC;
"""

# 📥 Lecture des données
df = pd.read_sql(query, conn)
df.columns = [c.upper() for c in df.columns]

# 📊 Affichage graphique
st.bar_chart(data=df.set_index("FORMATTED_WORK_TYPE")["NB_OFFRES"])
st.dataframe(df)
