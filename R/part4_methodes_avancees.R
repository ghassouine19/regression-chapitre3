
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

# Charger le dataset intégré 'mtcars' 
data(mtcars)
df <- mtcars


# Extraire la variable cible : mpg (consommation de carburant)
y <- df$mpg


# Construire le modèle de régression linéaire multiple
# mpg est la variable à expliquer
# '.' signifie que toutes les autres variables du dataset sont utilisées comme variables explicatives
initial_model <- lm(mpg ~ ., data = df)


# Afficher le résumé statistique du modèle
summary(initial_model)
# la régression semble de très bonne qualité puisque que R² = 86,9 %
# la valeur du p-value indique que le modèle est statistiquement très significatif 


# Afficher les graphiques de diagnostic du modèle
plot(initial_model)



# ==========================================
# 🔹 3) RÉGRESSION STAGEWISE : Yassine
# ==========================================

stagewise <- function(data, y_name, alpha = 0.05) {
  
  X_names <- setdiff(names(data), y_name) #obtenir toutes les variables sauf mpg
  
  selected <- c() #aucune variable sélectionnée pour le moment
  remaining <- X_names # toutes les variables au début
  
  current_residuals <- y
  n <- nrow(data) # nombre d'observations
  
  repeat {
    
    # Calculer les corrélations avec les résidus
    cors <- sapply(remaining, function(var) {
      cor(current_residuals, data[[var]])
    })
    
    # Sélectionner la meilleure variable (valeurs absolues)
    best_var <- names(which.max(abs(cors)))
    r <- cors[best_var] #stocker la corrélation de la variable sélectionnée
    
    # Degrés de liberté = n-(nombre de variables sélectionnées + 2)
    k <- length(selected)
    df <- n - k - 2
    
    
    t_stat <- r * sqrt(df) / sqrt(1 - r^2) # test de Student
    p_value <- 2 * pt(-abs(t_stat), df = df) #p-value (doit être inférieure à alpha)
    
    cat("Testing:", best_var, "| p-value =", p_value, "\n") #afficher le résultat : variables et p-value
    
    # Condition d'arrêt, lorsque la p-value est supérieure ou égale à alpha
    if (p_value >= alpha) {
      break
    }
    
    # Ajouter la variable si la p-value est inférieure à alpha
    selected <- c(selected, best_var)
    remaining <- setdiff(remaining, best_var) #supprimer la variable de la liste restante pour éviter de la sélectionner à nouveau
    
    # Mettre à jour le modèle
    formula <- as.formula(paste(y_name, "~", paste(selected, collapse = "+")))
    model <- lm(formula, data = data)
    
    # Mettre à jour les résidus pour une utilisation future
    current_residuals <- resid(model)
  }
  
  return(list(
    selected_variables = selected,
    final_model = if (length(selected) > 0) lm(as.formula(paste(y_name, "~", paste(selected, collapse = "+"))), data = data) else NULL
  )) #retourner les variables sélectionnées et le modèle final
}



result <- stagewise(mtcars, "mpg") #calling the function and stock the result

result$selected_variables #listing the selected variables
summary(result$final_model)

# ==========================================
# 🔹 4) RÉGRESSIONS PARTIELLES : Oussama
# ==========================================
# 🎯 Objectif :
# - Mesurer l’effet net d'une variable sur Y

# Afin de faciliter l’interprétation des régressions partielles, nous avons retenu les variables wt, 
# disp et hp, qui présentent un lien direct avec la consommation du véhicule (mpg).
# Cette sélection permet d’étudier clairement l’effet additionnel de la puissance (hp) après contrôle 
# du poids et de la cylindrée.

# -------------  🔷 🚀 Exemple 1 : tester hp   -------------
# Choisir les variables
# Y = mpg (consommation)
# X₁ = wt (poids)
# X₂ = disp (cylindrée)
# X₃ = hp (puissance) ← variable à tester

# Question : “Est-ce que hp apporte encore une information utile une fois wt et disp déjà prises en compte ?”


# Régression de Y sur (X₁, X₂)
model_Y <- lm(mpg ~ wt + disp, data = df)

# Résidus de Y
res_Y <- resid(model_Y)


# Régression de X₃:hp sur (X₁, X₂)
model_X <- lm(hp ~ wt + disp, data = mtcars)

# Résidus de X
res_X <- resid(model_X)

# Graphique de régression partielle
plot(res_X, res_Y,
     xlab = "Résidus hp",
     ylab = "Résidus mpg",
     main = "Régression partielle de hp sur mpg")

abline(lm(res_Y ~ res_X), col = "red")
# ➡️ relation faible à modérée car Les points ne sont pas bien alignés autour de la droite


# Régression des résidus
partial_model <- lm(res_Y ~ res_X)
summary(partial_model)

# Modèle complet
full_model <- lm(mpg ~ wt + disp + hp, data = mtcars)
summary(full_model)


# ➡️ Comparaison du Régression des résidus avec le modèle complet

# La régression des résidus fournit un coefficient estimé égal à -0.03116, identique à celui obtenu 
# dans le modèle complet, confirmant ainsi les propriétés théoriques de la régression partielle.
# La p-value associée (0.00843) indique que cet effet est statistiquement significatif.
# De plus, le coefficient de détermination partiel R²=0.2095 montre que la puissance explique 
# encore une part non négligeable de la variabilité résiduelle de mpg.
# Enfin, le modèle complet présente un R²=0.8268, indiquant une très bonne qualité globale d’ajustement.


# -------------  🔷 🚀 Exemple 2 : tester qsec   -------------

# résidus de Y2
model_Y2 <- lm(mpg ~ wt + disp, data = df)
res_Y2 <- resid(model_Y2)

# résidus de X2
model_X2 <- lm(qsec ~ wt + disp, data = df)
res_X2 <- resid(model_X2)

# Régression des résidus 2
partial_model2 <- lm(res_Y2 ~ res_X2)
summary(partial_model2)
# 
# ➡️ une augmentation de qsec d’une unité entraîne une augmentation moyenne de mpg d’environ 0.93.
#  p-value: 0.008771

# Après suppression des effets de wt et disp :
#   
#   ✔ qsec explique encore environ 20.76% de la variance résiduelle de mpg.
# 
# ➡️ Contribution non négligeable.


# Graphique de régression partielle 2
plot(res_X2, res_Y2)
abline(partial_model2, col="red")
# ➡️ pente positive → relation positive
# ➡️ dispersion dispersés → relation faible


# Modèle complet 2
full_model2 <- lm(mpg ~ wt + disp + qsec, data = df)
summary(full_model2)


# ➡️ Comparaison du Régression des résidus avec le modèle complet

# les coefficients sont égaux :
    # ✔ la régression partielle est validée.


# -------------  🔷 🚀 Exemple 3 : tester cyl = nombre de cylindres  -------------

model_Y3 <- lm(mpg ~ wt + disp, data = df)
res_Y3 <- resid(model_Y3)

model_X3 <- lm(cyl ~ wt + disp, data = df)
res_X3 <- resid(model_X3)

partial_model3 <- lm(res_Y3 ~ res_X3)
summary(partial_model3)
# ➡️ une augmentation d’un cylindre entraîne une diminution moyenne de mpg d’environ 1.78.

plot(res_X3, res_Y3)
abline(partial_model3, col="red")
# ➡️ pente negative → relation negative
# ➡️ dispersion dispersés → relation faible

full_model3 <- lm(mpg ~ wt + disp + cyl, data = df)
summary(full_model3)

# ➡️ Comparaison du Régression des résidus avec le modèle complet
# les coefficients sont égaux :
# ✔ la régression partielle est validée.

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