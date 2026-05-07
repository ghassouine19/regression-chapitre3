
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


# Choisir les variables
# Y = mpg (consommation)
# X₁ = wt (poids)
# X₂ = disp (cylindrée)
# X₃ = hp (puissance) ← variable à tester


# Régression de Y sur (X₁, X₂)
model_Y <- lm(mpg ~ wt + disp, data = df)

# Résidus de Y
res_Y <- resid(model_Y)


# Régression de X₃ sur (X₁, X₂)
model_X <- lm(hp ~ wt + disp, data = mtcars)

# Résidus de X
res_X <- resid(model_X)

# Graphique de régression partielle
plot(res_X, res_Y,
     xlab = "Résidus hp",
     ylab = "Résidus mpg",
     main = "Régression partielle de hp sur mpg")

abline(lm(res_Y ~ res_X), col = "red")
# relation faible à modérée car Les points ne sont pas bien alignés autour de la droite


# Régression des résidus
partial_model <- lm(res_Y ~ res_X)
summary(partial_model)


# Modèle complet
full_model <- lm(mpg ~ wt + disp + hp, data = mtcars)
summary(full_model)


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