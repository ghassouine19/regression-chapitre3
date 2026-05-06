# ==============================================================================
# PROJET : PRATIQUE DE LA RÉGRESSION LINÉAIRE MULTIPLE
# CHAPITRE 3.1 : DÉTECTION DE LA COLINÉARITÉ (GROUPE 1)
# Base de données : mtcars
# ==============================================================================

# Chargement des données et packages
# install.packages("corrplot")
# install.packages("car")
library(corrplot)
library(car)
data(mtcars)

exog_vars <- mtcars[, c("hp", "wt", "disp", "drat")]
Y <- mtcars$mpg
modele_global <- lm(mpg ~ hp + wt + disp + drat, data = mtcars)


cat("\n======================================================================\n")
cat(" SECTION 1.2 : MATRICE DE CORRÉLATION ET HEATMAP\n")
cat("======================================================================\n\n")

cor_matrix <- cor(exog_vars)
cat("Matrice de corrélation entre variables exogènes :\n")
print(round(cor_matrix, 3))

# Mettre en évidence la colinéarité (exemple hp / disp)
cor_hp_disp <- cor(mtcars$hp, mtcars$disp)
r2_hp_disp <- cor_hp_disp^2

cat("\n========== EXEMPLE DE COLINÉARITÉ ==========")
cat("\nCorrélation entre hp (puissance) et disp (cylindrée) :", round(cor_hp_disp, 3))
cat("\nCoefficient de détermination r² :", round(r2_hp_disp, 3))

if(abs(cor_hp_disp) > 0.8) {
  cat("\n→ Seuil > 0,8 atteint : colinéarité suspectée\n")
} else {
  cat("\n→ Seuil non atteint, mais corrélation modérée à surveiller\n")
}

# Heatmap
corrplot(cor_matrix, method = "color", type = "upper", 
         diag = FALSE, tl.col = "black", tl.srt = 45,
         title = "Corrélations entre exogènes - mtcars",
         mar = c(0,0,2,0))


cat("\n======================================================================\n")
cat(" SECTION 1.3 : ILLUSTRATION DE L'EFFET NOCIF DE LA COLINÉARITÉ\n")
cat("======================================================================\n\n")

X_mat <- as.matrix(cbind(1, exog_vars))
p <- ncol(exog_vars)
n <- nrow(exog_vars)

# 1.3.1 Colinéarité parfaite
cat("--- 1.3.1 COLINÉARITÉ PARFAITE ---\n")
rang_XtX <- qr(t(X_mat) %*% X_mat)$rank
cat("Rang de X'X :", rang_XtX, "| p + 1 :", p + 1, "\n")
if (rang_XtX < p + 1) {
  cat(">>> COLINÉARITÉ PARFAITE DÉTECTÉE : inverse(X'X) n'existe pas.\n")
} else {
  cat(">>> Pas de colinéarité parfaite dans mtcars.\n")
}

# Simulation d'une colinéarité parfaite
cat("\n--- Simulation d'une colinéarité parfaite ---\n")
cat("Ajout de la variable hp2 = 2 * hp\n")
X_parfait <- cbind(exog_vars, hp2 = exog_vars$hp * 2)
X_mat_parfait <- as.matrix(cbind(1, X_parfait))
if (qr(t(X_mat_parfait) %*% X_mat_parfait)$rank < ncol(X_parfait) + 1) {
  cat(">>> COLINÉARITÉ PARFAITE SIMULÉE : inverse(X'X) n'existe pas.\n\n")
}

# 1.3.2 Colinéarité forte et t de Student
cat("--- 1.3.2 COLINÉARITÉ FORTE ET t DE STUDENT ---\n")
XtX <- t(X_mat) %*% X_mat

# Note: Déterminant calculé sur la matrice de corrélation (plus robuste pour l'analyse)
det_C <- det(cor_matrix)
cat("Déterminant de la matrice de corrélation (C) :", round(det_C, 5), "\n")
if (det_C < 0.1) {
  cat(">>> Déterminant très proche de zéro → colinéarité forte.\n")
}

# Calcul de la variance et du t de Student manuel
XtX_inv <- solve(XtX)
sigma2 <- summary(modele_global)$sigma^2
var_cov <- sigma2 * XtX_inv
variances <- diag(var_cov)
ecarts_types <- sqrt(variances)
coefs <- coef(modele_global)
t_student <- coefs / ecarts_types

cat("\nComparaison des t de Student :\n")
resultats_maths <- data.frame(
  Coefficient = round(coefs, 4),
  EcartType = round(ecarts_types, 6),
  t_Student = round(t_student, 3),
  p_value = round(summary(modele_global)$coefficients[, 4], 4)
)
print(resultats_maths)

if (abs(t_student["disp"]) < 2) {
  cat("\n>>> t de Student de disp < 2 → disp paraît NON SIGNIFICATIF à tort.\n")
  cat(">>> C'est l'illustration parfaite de l'effet nocif de la colinéarité !\n")
}


cat("\n======================================================================\n")
cat(" SECTION 1.4.1 : TEST DE KLEIN\n")
cat("======================================================================\n\n")

R2 <- summary(modele_global)$r.squared
cat("R² calculé automatiquement =", round(R2, 4), "\n\n")

mat_cor_carre <- cor_matrix^2
cat("Matrice des corrélations croisées au carré (r²) :\n")
print(round(mat_cor_carre, 4))

cat("\nTest de Klein - Comparaison R² vs r² :\n")
cat("------------------------------------------------------------\n")
cat(sprintf("%-15s %-15s %-15s %-15s\n", "Variable i", "Variable j", "r²", "R² - r²"))
cat("------------------------------------------------------------\n")

colin_detect <- FALSE
colin_paires <- c()
proches_paires <- c()

for(i in 1:4) {
  for(j in 1:4) {
    if(i < j) {
      r2_ij <- mat_cor_carre[i,j]
      var_i <- rownames(cor_matrix)[i]
      var_j <- colnames(cor_matrix)[j]
      difference <- R2 - r2_ij
      
      cat(sprintf("%-15s %-15s %-15.4f %-15.4f\n", var_i, var_j, r2_ij, difference))
      
      if(r2_ij > R2) {
        colin_detect <- TRUE
        colin_paires <- c(colin_paires, paste(var_i, "-", var_j, "(r²=", round(r2_ij, 4), ")"))
      } else if(r2_ij > 0.8 * R2) {
        proches_paires <- c(proches_paires, paste(var_i, "-", var_j, "(r²=", round(r2_ij, 4), ")"))
      }
    }
  }
}

cat("\nInformations Supplémentaires : Les 3 plus fortes corrélations absolues :\n")
cor_values <- cor_matrix
diag(cor_values) <- NA
max_cors <- sort(abs(cor_values), decreasing = TRUE)[1:3]
for(k in 1:3) {
  for(i in 1:4) {
    for(j in 1:4) {
      if(i < j && abs(cor_matrix[i,j]) == max_cors[k]) {
        cat(sprintf("  %d. %s - %s : |r| = %.4f (r² = %.4f)\n", 
                    k, rownames(cor_matrix)[i], colnames(cor_matrix)[j], 
                    abs(cor_matrix[i,j]), cor_matrix[i,j]^2))
      }
    }
  }
}


cat("\n======================================================================\n")
cat(" SECTION 1.4.2 : FACTEUR D'INFLATION DE LA VARIANCE (VIF)\n")
cat("======================================================================\n\n")

# Méthode avec le package car
cat("1. Valeurs du VIF (Méthode automatique via package 'car') :\n")
vif_standard <- vif(modele_global)
print(round(vif_standard, 2))

# Méthode matricielle
cat("\n2. Calcul matriciel du VIF via l'inverse de la matrice (C^-1) :\n")
C_inv <- solve(cor_matrix)
vif_manuel <- diag(C_inv)
tolerance <- 1 / vif_manuel

tableau_vif <- data.frame(
  Variable = names(vif_manuel),
  VIF_Calcule = round(vif_manuel, 2),
  Tolerance = round(tolerance, 3)
)
print(tableau_vif)

# Graphe VIF
couleurs_vif <- ifelse(tableau_vif$VIF_Calcule > 5, "firebrick", "steelblue")
barplot(tableau_vif$VIF_Calcule, 
        names.arg = tableau_vif$Variable, 
        col = couleurs_vif, 
        main = "Niveaux de VIF par variable explicative", 
        ylab = "Valeur du VIF",
        ylim = c(0, max(tableau_vif$VIF_Calcule) + 2))
abline(h = 5, col = "red", lwd = 2, lty = 2)
legend("topright", legend=c("VIF Acceptable (< 5)", "VIF Critique (> 5)"), 
       fill=c("steelblue", "firebrick"))


cat("\n======================================================================\n")
cat(" SECTION 1.4.3 : COHÉRENCE DES SIGNES (L'ABERRATION)\n")
cat("======================================================================\n\n")

corr_simples <- cor(mtcars$mpg, exog_vars)[1,]
coef_multiples <- coef(modele_global)[-1]

cat("Vérification des signes (Boucle) :\n")
for(i in 1:length(coef_multiples)) {
  if(sign(corr_simples[i]) != sign(coef_multiples[i])) {
    cat("⚠️ CONFLIT pour", names(coef_multiples)[i], 
        ": corrélation =", round(corr_simples[i], 3),
        "(signe", sign(corr_simples[i]), ") vs coefficient =", 
        round(coef_multiples[i], 4), "(signe", sign(coef_multiples[i]), ")\n")
  } else {
    cat("✓", names(coef_multiples)[i], ": signes cohérents\n")
  }
}

tableau_signes <- data.frame(
  Correlation_Simple = round(corr_simples, 3),
  Coef_Regression = round(coef_multiples, 3)
)
tableau_signes$Conflit <- sign(tableau_signes$Correlation_Simple) != sign(tableau_signes$Coef_Regression)

cat("\nTableau Récapitulatif :\n")
print(tableau_signes)

cat("\n======================================================================\n")
cat(" SECTION 1.4.4 : Extension à l'ensemble des variables explicatives \n")
cat("======================================================================\n\n")
# Heatmap avec toutes les variables explicatives

exog_all <- mtcars[, c("cyl", "disp", "hp", "drat", "wt", 
                       "qsec", "vs", "am", "gear", "carb")]

cor_all <- cor(exog_all)

corrplot(cor_all, method = "color", type = "upper", diag = FALSE,
         tl.col = "black", tl.srt = 45,
         title = "Corrélations entre toutes les variables explicatives - mtcars",
         mar = c(0,0,2,0))

cat("\n======================================================================\n")
cat(" FIN DU SCRIPT - TRANSITION VERS LA SÉLECTION DE VARIABLES\n")
cat("======================================================================\n")
