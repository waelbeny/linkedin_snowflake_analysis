import streamlit as st
import pandas as pd
import snowflake.connector

st.set_page_config(page_title="Top 10 Job Titles", layout="centered")
st.title("📊 Top 10 des postes les plus publiés")

# 🔐 Connexion Snowflake
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
SELECT title, COUNT(*) AS nb_postes
FROM job_postings
GROUP BY title
ORDER BY nb_postes DESC
LIMIT 10;
"""

# 📥 Lire les données
df = pd.read_sql(query, conn)

# ✅ Corriger les noms de colonnes (Snowflake renvoie souvent en majuscules)
df.columns = [c.upper() for c in df.columns]

# 📋 Afficher noms de colonnes pour vérif
st.write("📋 Colonnes retournées :", df.columns.tolist())

# 📊 Affichage
st.bar_chart(data=df.set_index("TITLE")["NB_POSTES"])
st.dataframe(df)



