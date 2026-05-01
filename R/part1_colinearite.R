# Partie 1 (3.1) — Détection de la colinéarité
# ============================================
# Partie : Introduction + 3.1.1 Conséquences
# ============================================

# Charger les données
data(mtcars)

# -------------------------------------------------
# 1. Matrice de corrélation entre EXOGÈNES uniquement
# -------------------------------------------------
exog_vars <- mtcars[, c("hp", "wt", "disp", "drat")]
cor_matrix <- cor(exog_vars)
print("Matrice de corrélation entre variables exogènes :")
print(round(cor_matrix, 3))

# -------------------------------------------------
# 2. Mettre en évidence la colinéarité (exemple hp / disp)
# -------------------------------------------------
cor_hp_disp <- cor(mtcars$hp, mtcars$disp)
r2_hp_disp <- cor_hp_disp^2

cat("\n========== EXEMPLE DE COLINÉARITÉ ==========")
cat("\nCorrélation entre hp (puissance) et disp (cylindrée) :", round(cor_hp_disp, 3))
cat("\nCoefficient de détermination r² :", round(r2_hp_disp, 3))

if(abs(cor_hp_disp) > 0.8) {
  cat("\n→ Seuil > 0,8 atteint : colinéarité suspectée")
} else {
  cat("\n→ Seuil non atteint, mais corrélation modérée à surveiller")
}

# -------------------------------------------------
# 3. Illustration des conséquences : signes contradictoires
# -------------------------------------------------
modele <- lm(mpg ~ hp + wt + disp + drat, data = mtcars)
cor_simples <- cor(mtcars$mpg, exog_vars)[1,]
coeff <- coef(modele)[-1]

cat("\n\n========== TEST DE COHÉRENCE DES SIGNES ==========")
cat("\nCorrélations simples (mpg vs exogènes) :")
print(round(cor_simples, 3))

cat("\nCoefficients de la régression multiple :")
print(round(coeff, 4))

cat("\nVérification des signes :")
for(i in 1:length(coeff)) {
  if(sign(cor_simples[i]) != sign(coeff[i])) {
    cat("\n⚠️ CONFLIT pour", names(coeff)[i], 
        ": corrélation =", round(cor_simples[i], 3),
        "(signe", sign(cor_simples[i]), ") vs coefficient =", 
        round(coeff[i], 4), "(signe", sign(coeff[i]), ")")
  } else {
    cat("\n✓", names(coeff)[i], ": signes cohérents")
  }
}

# -------------------------------------------------
# 4. Visualisation (heatmap)
# -------------------------------------------------
library(corrplot)
corrplot(cor_matrix, method = "color", type = "upper", 
         diag = FALSE, tl.col = "black", tl.srt = 45,
         title = "Corrélations entre exogènes - mtcars",
         mar = c(0,0,2,0))
