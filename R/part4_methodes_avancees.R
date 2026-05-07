
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

stagewise <- function(data, y_name, alpha = 0.25) {
  
  X_names <- setdiff(names(data), y_name) #obtenir toutes les variables sauf mpg
  
  selected <- c() #aucune variable sélectionnée pour le moment
  remaining <- X_names # toutes les variables au début
  
  current_residuals <- y
  n <- nrow(data) # nombre d'observations
  
  step <- 1
  
  cat("====================================\n")
  cat("RÉGRESSION FORWARD STAGEWISE\n")
  cat("====================================\n\n")
  
  cat("Étape 0 : intercept uniquement\n\n")
  
  
  repeat {
    
    if(length(remaining) == 0) break
    
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
    
    cat(sprintf("──────── Étape %d ────────\n", step))
    cat(sprintf("Variable candidate : %s\n", best_var))
    cat(sprintf("Corrélation avec résidus : %.3f\n", r))
    cat(sprintf("p-value : %.6f\n", p_value))
    
    
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
    
    
    # Statistiques
    r2_adj <- summary(model)$adj.r.squared
    aic_val <- AIC(model)
    
    cat(sprintf("Modèle courant : %s\n",
                paste(selected, collapse = " + ")))
    
    cat(sprintf("R² ajusté : %.3f\n", r2_adj))
    cat(sprintf("AIC : %.3f\n\n", aic_val))
    
    step <- step + 1
  }
  
  
  cat("====================================\n")
  cat("MODÈLE FINAL\n")
  cat("====================================\n")
  
  final_model <- if(length(selected) > 0)
    lm(as.formula(paste(y_name, "~", paste(selected, collapse = " + "))),
       data = data)
  else NULL
  
  return(list(
    selected_variables = selected,
    final_model = final_model
  ))
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
# Objectif : vérifier que les 3 variables retenues par la stagewise
#            (wt, qsec, am) n'apportent pas d'information redondante.
#
# Trois niveaux d'analyse (d'après Rakotomalala) :
#   Niveau 1 — VIF local          : quantifie l'inflation numérique de la variance
#   Niveau 2 — Test F auxiliaire  : détecte statistiquement la dépendance
#   Niveau 3 — Corrélations partielles : lien pur entre deux prédicteurs
#                                        après neutralisation du troisième
#
# Règle de décision :
#   VIF < 5  → inflation acceptable (seuil critique : 10)
#   C'est le VIF qui juge la sévérité, pas le test F.


library(car)

model_stagewise <- result$final_model   # mpg ~ wt + qsec + am
model_full      <- initial_model        # mpg ~ . (10 variables)
vars_X          <- result$selected_variables   # c("wt", "qsec", "am")
data_X          <- df[, vars_X]
n               <- nrow(data_X)         # 32 observations
p               <- length(vars_X)       # 3 variables


# ------------------------------------------
# 5a. BASELINE — VIF du modèle COMPLET
#
# But : montrer à quel point la multicolinéarité est sévère
#       quand on inclut toutes les variables sans sélection.
# Note : ces VIF décrivent le modèle complet uniquement,
#        ils ne s'appliquent PAS au modèle stagewise.
# ------------------------------------------

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  BASELINE — VIF MODÈLE COMPLET (Référence d'échec)      ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

vif_full <- vif(model_full)

for (nm in names(vif_full)) {
  flag <- if (vif_full[nm] >= 10) "🔴" else if (vif_full[nm] >= 5) "🟡" else "🟢"
  cat(sprintf("  %-6s : VIF = %5.2f  %s\n", nm, vif_full[nm], flag))
}

cat("\n")
cat("→ disp (21.6) et cyl (15.4) présentent une colinéarité critique.\n")
cat("  wt (15.2) est confondu avec disp et cyl.\n")
cat("  Conséquence : aucun coefficient individuel significatif\n")
cat("  malgré R² = 0.869 → symptôme classique de multicolinéarité sévère.\n\n")
cat(sprintf("  VIF max modèle complet   (10 vars) : %.2f  🔴\n", max(vif_full)))
cat(sprintf("  VIF max modèle stagewise ( 3 vars) : voir section 5b ci-dessous  🟢\n\n"))


# ------------------------------------------
# 5b. NIVEAUX 1 & 2 — VIF local + Test F auxiliaire
#
# Pour chaque variable Xᵢ parmi (wt, qsec, am) :
#   → On régresse Xᵢ sur les deux autres variables du modèle
#   → R² auxiliaire → VIF = 1 / (1 - R²aux)         [Éq. 3.13]
#   → Test F = [R²/(p-1)] / [(1-R²)/(n-p)]           [Éq. 3.14]
#
# Lecture des résultats :
#   Test F significatif (p < 0.05) → dépendance statistiquement détectable
#   VIF < 3                        → sévérité faible, coefficients stables
#   → Le test F détecte la dépendance, le VIF en juge la gravité
# ------------------------------------------

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  NIVEAUX 1 & 2 — VIF LOCAL + TEST F (Éq. 3.13 & 3.14)  ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")
cat("Variables du modèle stagewise :", paste(vars_X, collapse = ", "), "\n\n")

for (v in vars_X) {
  others  <- setdiff(vars_X, v)
  f_aux   <- as.formula(paste(v, "~", paste(others, collapse = " + ")))
  mod_aux <- lm(f_aux, data = data_X)
  r2_aux  <- summary(mod_aux)$r.squared

  vif_v   <- 1 / (1 - r2_aux)
  f_val   <- (r2_aux / (p - 1)) / ((1 - r2_aux) / (n - p))
  p_val_f <- pf(f_val, df1 = p - 1, df2 = n - p, lower.tail = FALSE)

  flag <- if (vif_v >= 10) "🔴" else if (vif_v >= 5) "🟡" else "🟢"

  cat(sprintf("── Cible : %s ~ %s\n", v, paste(others, collapse = " + ")))
  cat(sprintf("   R² aux : %.4f | VIF : %.2f  %s\n", r2_aux, vif_v, flag))
  cat(sprintf("   Test F(%d,%d) = %.3f | p-value : %.3e\n\n", p - 1, n - p, f_val, p_val_f))
}

# Résultats obtenus :
#   wt  : VIF = 2.48 → Test F significatif (p < 0.05), dépendance détectable
#                       mais inflation de variance faible → acceptable
#   qsec: VIF = 1.36 → pratiquement indépendante de wt et am
#   am  : VIF = 2.54 → même constat que wt, dépendance modérée mais acceptable
#
#   Tous les VIF sont bien sous le seuil de 5 → aucune multicolinéarité problématique


# ------------------------------------------
# 5c. NIVEAU 3 — Matrice des corrélations partielles
#
# Éq. 3.19 : r_ij|k = -v_ij / sqrt(v_ii * v_jj)
#   où v_ij sont les éléments de C⁻¹ (inverse de la matrice de corrélation)
#
# Corrélation brute    : lien apparent entre deux variables (sans contrôle)
# Corrélation partielle : lien pur après neutralisation de la 3ème variable
#
# Si partielle > brute → effet SUPPRESSEUR :
#   la 3ème variable masquait une partie du vrai lien entre les deux autres
# ------------------------------------------

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  NIVEAU 3 — CORRÉLATIONS PARTIELLES (Éq. 3.19)          ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

C      <- cor(data_X)
C_inv  <- solve(C)
v_diag <- diag(C_inv)

# r_ij|k = -v_ij / sqrt(v_ii * v_jj)
p_cor <- -C_inv / sqrt(v_diag %*% t(v_diag))
diag(p_cor) <- 1

cat("Corrélation BRUTE (matrice C) :\n")
print(round(C, 3))
cat("\nCorrélation PARTIELLE — lien pur après neutralisation (Éq. 3.19) :\n")
print(round(p_cor, 3))

cat("\n")
cat("→ Les corrélations partielles sont systématiquement plus fortes\n")
cat("  que les corrélations brutes → effet SUPPRESSEUR confirmé.\n")
cat("  Exemple : wt ↔ am passe de -0.692 (brut) à -0.765 (partiel)\n")
cat("  → am masquait une partie du lien réel entre poids et consommation.\n")
cat("  Exemple : wt ↔ qsec passe de -0.175 (brut) à -0.476 (partiel)\n")
cat("  → am absorbait aussi une partie du lien entre poids et vitesse.\n")
cat("  Ces valeurs (-0.48 à -0.77) restent cohérentes avec les VIF\n")
cat("  obtenus (max 2.54) — bien sous le seuil critique de 5.\n\n")

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  SYNTHÈSE RÉGRESSIONS CROISÉES                          ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")
cat("  Niveau 1 — Numérique   : VIF max = 2.54 (seuil : 5)\n")
cat("                           → inflation de variance faible et acceptable.\n\n")
cat("  Niveau 2 — Statistique : Tests F significatifs pour wt et am (p < 0.05)\n")
cat("                           → dépendances détectables, mais VIF < 3\n")
cat("                           → sévérité jugée acceptable (c'est le VIF qui tranche).\n\n")
cat("  Niveau 3 — Géométrique : corrélations partielles > brutes pour toutes les paires\n")
cat("                           → effet suppresseur : am atténuait les liens wt↔qsec et wt↔am.\n")
cat("                           → cohérent avec VIF 2.48 / 1.36 / 2.54.\n\n")
cat("  Conclusion : malgré les dépendances détectées, VIF < 3 confirme\n")
cat("  que les coefficients de mpg ~", paste(vars_X, collapse = " + "), "sont stables.\n\n")


# ==========================================
# 🔹 6) VALIDATION CROISÉE : Ilham
# ==========================================
# Objectif : vérifier que le modèle stagewise généralise bien
#            sur des données non vues, et détecter un éventuel
#            surapprentissage du modèle complet.
#
# Deux méthodes :
#   Méthode 1 — Train/Test 70/30 : rapide mais sensible au tirage (n=32 petit)
#   Méthode 2 — LOOCV            : entraîne 32 modèles, plus robuste sur petits datasets
#
# Critère : RMSE (Root Mean Squared Error, en mpg)
#   → Plus le RMSE est bas, meilleure est la prédiction hors-échantillon

library(boot)
set.seed(123)


# ------------------------------------------
# 6a. Train / Test 70% / 30%
#     22 observations pour l'entraînement, 10 pour le test
#     Limite : sur n=32, le résultat peut varier selon le tirage
# ------------------------------------------

train_idx <- sample(1:nrow(df), size = floor(0.7 * nrow(df)))
train     <- df[train_idx, ]
test      <- df[-train_idx, ]

model_tt_full  <- lm(mpg ~ .,                  data = train)
model_tt_stage <- lm(formula(model_stagewise), data = train)

rmse_full_tt  <- sqrt(mean((test$mpg - predict(model_tt_full,  test))^2))
rmse_stage_tt <- sqrt(mean((test$mpg - predict(model_tt_stage, test))^2))

cat("=== VALIDATION CROISÉE — TRAIN/TEST (70/30) ===\n")
cat("RMSE Modèle Complet   :", round(rmse_full_tt,  3), "mpg\n")
cat("RMSE Modèle Stagewise :", round(rmse_stage_tt, 3), "mpg\n")
cat("→ Stagewise meilleur :", ifelse(rmse_stage_tt < rmse_full_tt, "OUI ✅", "NON ⚠️"), "\n\n")
# Résultat : Stagewise RMSE (2.131) < Complet RMSE (2.281) → OUI ✅
# Le modèle à 3 variables prédit mieux que le modèle à 10 variables


# ------------------------------------------
# 6b. LOOCV — Leave-One-Out Cross-Validation
#     On entraîne 32 modèles en excluant une observation à chaque fois.
#     Méthode préférée sur ce dataset car plus robuste que le simple split.
#     delta[1] = MSE moyen → on prend sqrt() pour obtenir le RMSE
# ------------------------------------------

glm_full  <- glm(mpg ~ .,                  data = df, family = gaussian)
glm_stage <- glm(formula(model_stagewise), data = df, family = gaussian)

rmse_full_loo  <- sqrt(cv.glm(df, glm_full)$delta[1])
rmse_stage_loo <- sqrt(cv.glm(df, glm_stage)$delta[1])

cat("=== VALIDATION CROISÉE — LOOCV ===\n")
cat("RMSE Modèle Complet   :", round(rmse_full_loo,  3), "mpg\n")
cat("RMSE Modèle Stagewise :", round(rmse_stage_loo, 3), "mpg\n")
cat("→ Stagewise meilleur :", ifelse(rmse_stage_loo < rmse_full_loo, "OUI ✅", "NON ⚠️"), "\n")
cat("→ Gain généralisation :", round((rmse_full_loo - rmse_stage_loo) / rmse_full_loo * 100, 1), "%\n\n")

# Résultats :
#   Complet   : RMSE LOOCV = 3.490 mpg >> erreur résiduelle (≈2.65)
#               → écart important = surapprentissage confirmé
#               10 variables pour 32 observations = trop peu de degrés de liberté
#   Stagewise : RMSE LOOCV = 2.689 mpg ≈ erreur résiduelle (≈2.46)
#               → écart faible = le modèle généralise correctement
#
#   Gain : 23% de réduction de l'erreur hors-échantillon avec 7 variables de moins


# ==========================================
# 🔹 7) COMPARAISON DES MODÈLES (ALL TEAM)
# ==========================================
# Critères comparés :
#   R² ajusté  : ajustement aux données (pénalise les variables inutiles)
#   AIC        : équilibre ajustement / complexité (plus bas = meilleur)
#   RMSE TT    : erreur sur le jeu de test 70/30
#   RMSE LOOCV : erreur hors-échantillon robuste (critère principal sur n=32)


# ------------------------------------------
# 7a. Tableau comparatif
# ------------------------------------------

comparison <- data.frame(
  Modele     = c("Complet (10 vars)", "Stagewise (3 vars)"),
  Nb_vars    = c(length(coef(model_full)) - 1,
                 length(coef(model_stagewise)) - 1),
  R2_ajuste  = round(c(summary(model_full)$adj.r.squared,
                       summary(model_stagewise)$adj.r.squared), 3),
  AIC        = round(c(AIC(model_full), AIC(model_stagewise)), 1),
  RMSE_TT    = round(c(rmse_full_tt,  rmse_stage_tt),  3),
  RMSE_LOOCV = round(c(rmse_full_loo, rmse_stage_loo), 3)
)

cat("=== TABLEAU COMPARATIF ===\n")
print(comparison)

# Lecture :
#   R² ajusté : 0.834 (stagewise) > 0.807 (complet)
#               → meilleur ajustement avec 7 variables de moins
#   AIC       : 154.1 (stagewise) < 163.7 (complet)
#               → meilleur équilibre complexité / performance
#   RMSE LOOCV: 2.689 (stagewise) < 3.490 (complet)
#               → meilleure généralisation hors-échantillon
#   Conclusion : le modèle stagewise domine sur TOUS les critères


# ------------------------------------------
# 7b. Visualisation — Barplots AIC et RMSE LOOCV
#     Rouge = modèle complet | Bleu = modèle stagewise
#     Pour les deux métriques : plus bas = meilleur
# ------------------------------------------

par(mfrow = c(1, 2))

barplot(c(AIC(model_full), AIC(model_stagewise)),
        names.arg = c("Complet", "Stagewise"),
        col  = c("tomato", "steelblue"),
        main = "AIC (plus bas = meilleur)",
        ylab = "AIC",
        ylim = c(140, 175))
abline(h = AIC(model_stagewise), lty = 2, col = "steelblue")
# Barre bleue nettement plus basse → stagewise mieux calibré

barplot(c(rmse_full_loo, rmse_stage_loo),
        names.arg = c("Complet", "Stagewise"),
        col  = c("tomato", "steelblue"),
        main = "RMSE LOOCV (plus bas = meilleur)",
        ylab = "RMSE (mpg)",
        ylim = c(0, 4))
abline(h = rmse_stage_loo, lty = 2, col = "steelblue")
# Barre rouge haute → surapprentissage du modèle complet confirmé

par(mfrow = c(1, 1))


# ==========================================
# 🔹 8) CONCLUSION (ALL TEAM)
# ==========================================

cat("╔══════════════════════════════════════════════════════════╗\n")
cat("║  CONCLUSION — MODÈLE RETENU                             ║\n")
cat("╚══════════════════════════════════════════════════════════╝\n\n")

coefs <- coef(model_stagewise)
cat("Équation du modèle :\n")
cat(sprintf("  mpg^ = %.3f + (%.3f)*wt + (%.3f)*qsec + (%.3f)*am\n\n",
            coefs["(Intercept)"], coefs["wt"], coefs["qsec"], coefs["am"]))

cat("Performances du modèle final :\n")
cat(sprintf("  R² ajusté  : %.3f\n", summary(model_stagewise)$adj.r.squared))
cat(sprintf("  AIC        : %.1f\n",  AIC(model_stagewise)))
cat(sprintf("  RMSE LOOCV : %.3f mpg\n\n", rmse_stage_loo))

cat("Interprétation des coefficients :\n")
cat("  wt   (poids)        : +1 unité (≈453 kg) → -3.92 mpg  [effet dominant]\n")
cat("  qsec (temps ¼ mile) : +1 seconde          → +1.23 mpg  [voiture plus lente = plus économe]\n")
cat("  am   (transmission) : manuelle vs auto    → +2.94 mpg  [manuelle consomme moins]\n\n")

cat("Synthèse méthodologique :\n")
cat("  - Stagewise : variables sélectionnées par corrélation maximale avec les résidus\n")
cat("  - Arrêt automatique à l'étape 3 → modèle final : wt + qsec + am\n")
cat("  - VIF < 3 pour les 3 variables → multicolinéarité acceptable\n")
cat("  - LOOCV confirme une meilleure généralisation : +23% vs modèle complet\n\n")

cat("Limites :\n")
cat("  - Petit dataset (n=32) : résultats sensibles aux valeurs extrêmes\n")
cat("  - Données de 1974 : les relations peuvent être différentes aujourd'hui\n")
cat("  - Stagewise forward uniquement : ne reconsidère pas les variables déjà entrées\n")
































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