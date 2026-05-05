
#############################################
# 📌 PROJECT: Régression Linéaire Multiple
# Dataset: mtcars
# File: part4.R
# Team: [Oussama - Yassine - Ilham]
#############################################


# ==========================================
# 🔹 1) WORKFLOW GLOBAL (ALL TEAM)
# ==========================================
# Étapes du projet :
# 1. Charger les données
# 2. Construire un modèle initial
# 3. Appliquer :
#    - Régression stepwise
#    - Régressions partielles
#    - Régressions croisées
# 4. Comparer les modèles
# 5. Conclure


# ==========================================
# 🔹 2) DATASET : Oussama
# ==========================================

# Charger le dataset intégré 'mtcars' dans l'environnement R
data(mtcars)
df <- mtcars

# Extraire la variable cible (variable dépendante) : mpg (consommation de carburant)
y <- df$mpg

# Construire le modèle de régression linéaire multiple
# mpg est la variable à expliquer
# '.' signifie que toutes les autres variables du dataset sont utilisées comme variables explicatives
initial_model <- lm(mpg ~ ., data = df)

# Afficher le résumé statistique du modèle
# Contient :
# - les coefficients estimés (Estimate)
# - leur significativité (p-value)
# - la qualité globale du modèle (R², R² ajusté)
# - les statistiques de test (t-value, F-statistic)
summary(initial_model)

# Afficher les graphiques de diagnostic du modèle
plot(initial_model)

# ==========================================
# 🔹 3) RÉGRESSION STAGEWISE : Yassine
# ==========================================
# 🎯 Objectif :
# - Sélection automatique des variables importantes
# - Minimiser le critère AIC

# ⚙️ Étapes :
# - Construire modèle complet :
model_full <- lm(mpg ~ ., data = df)
# - Construire modèle vide :
model_null <- lm(mpg ~ 1, data = df)
# - Appliquer stepwise (both directions) :
model_step <- step(model_null, 
                   scope = list(lower = model_null, upper = model_full), 
                   direction = "both")


# - Obtenir modèle final
summary(model_step)


# 📊 Résultats attendus :
# - Variables sélectionnées :
formula(model_step)
# - Valeur AIC : 
AIC(model_step)


# 🧠 Interprétation à faire :
# - Quelles variables ont été retenues ?
#Les variables retenus sont : wt, cyl et hp

# - Pourquoi certaines ont été supprimées ?
#Certaines variables ont été supprimées car elles n'améliorent pas le modèle selon le critère AIC.
#En particulier, les variables présentant des valeurs p-value ont été considérées comme non significatives.
#D'autres ont été supprimées en raison de leur redondance, leur information étant déjà prise en compte par d'autres variables du modèle.


# - Comparaison avec modèle complet (AIC, R²) :
AIC(model_full)
AIC(model_step)
#La valeur de l'AIC après utilisation de la méthode stepwise est de "155,46", ce qui est inférieur à l'AIC initial de "163,70"
summary(model_full)$r.squared
summary(model_step)$r.squared
#R² reste similaire "0.86 ≈ 0,84", ce qui signifie que nous obtenons des performances similaires avec moins de variables.



# ==========================================
# 🔹 4) RÉGRESSIONS PARTIELLES : Oussama
# ==========================================
# 🎯 Objectif :
# - Mesurer l’effet net de chaque variable sur Y
# - Contrôler les autres variables

# ⚙️ Étapes :
# - Construire modèle complet
# - Générer les graphiques (avPlots)

# 📊 Résultats attendus :
# - Graphiques de régression partielle

# 🧠 Interprétation à faire :
# - Quelles variables ont un effet fort ?
# - Les relations sont-elles linéaires ?
# - Y a-t-il des outliers ?




# ==========================================
# 🔹 5) RÉGRESSIONS CROISÉES : Ilham
# ==========================================
# 🎯 Objectif :
# - Évaluer la performance du modèle
# - Tester la généralisation

# ⚙️ Étapes :
# - Diviser les données (train/test)
# - Construire le modèle sur train
# - Faire des prédictions sur test
# - Calculer RMSE
# - Appliquer LOOCV

# 📊 Résultats attendus :
# - RMSE
# - Erreur LOOCV

# 🧠 Interprétation à faire :
# - RMSE faible = bon modèle ?
# - Le modèle généralise-t-il bien ?
# - Y a-t-il du surapprentissage ?




# ==========================================
# 🔹 6) COMPARAISON DES MODÈLES (ALL TEAM)
# ==========================================
# Étapes :
# - Comparer AIC (stepwise vs modèle complet)
# - Comparer RMSE
# - Évaluer la stabilité

# 🧠 Interprétation :
# - Quel modèle est le meilleur ?
# - Pourquoi ?

# 👉 Responsable : TOUS


# ==========================================
# 🔹 7) CONCLUSION (ALL TEAM)
# ==========================================
# À rédiger :
# - Variables les plus importantes
# - Performance globale
# - Capacité de généralisation
# - Limites du modèle

# 👉 Responsable : TOUS