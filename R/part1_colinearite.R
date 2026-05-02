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
install.packages("corrplot")
library(corrplot)
corrplot(cor_matrix, method = "color", type = "upper", 
         diag = FALSE, tl.col = "black", tl.srt = 45,
         title = "Corrélations entre exogènes - mtcars",
         mar = c(0,0,2,0))






# ===========================================
# PARTIE 2 - TEST DE KLEIN POUR DÉTECTER LA COLINÉARITÉ
# ===========================================
# Variables : y = CONSO (mpg)
#             x1 = hp (puissance)
#             x2 = wt (poids)
#             x3 = disp (cylindrée)
#             x4 = drat (rapport de pont)
# ===========================================

# ===========================================
# ÉTAPE 1 : Calcul du R² de la régression multiple
# ===========================================
# Régression avec mpg comme variable dépendante
regression <- lm(mpg ~ hp + wt + disp + drat, data = mtcars)
R2 <- summary(regression)$r.squared

cat("\n\n=========================================\n")
cat("ÉTAPE 1 : Coefficient de détermination R²\n")
cat("=========================================\n")
cat("R² calculé automatiquement =", round(R2, 4), "\n\n")

# ===========================================
# ÉTAPE 2 : Matrice des corrélations croisées 
# ===========================================

# Utilisation de la matrice de corrélation calculée dans la Partie 1
mat_cor <- cor_matrix

cat("=========================================\n")
cat("ÉTAPE 2 : Matrice des corrélations croisées (r)\n")
cat("=========================================\n")
print(round(mat_cor, 4))

# Calcul du carré des corrélations (r²)
mat_cor_carre <- mat_cor^2

cat("\n=========================================\n")
cat("ÉTAPE 2 (suite) : Matrice des corrélations croisées au carré (r²)\n")
cat("=========================================\n")
print(round(mat_cor_carre, 4))

# ===========================================
# ÉTAPE 3 : Test de Klein
# Règle : Colinéarité si R² < r²(xi, xj)
# ===========================================
cat("\n=========================================\n")
cat("ÉTAPE 3 : Test de Klein - Comparaison R² vs r²\n")
cat("=========================================\n")
cat("Règle : Il y a colinéarité si R² < r²(xi, xj)\n")
cat(paste0("R² = ", round(R2, 4), "\n\n"))

# Tableau comparatif
cat("Comparaison détaillée :\n")
cat("------------------------------------------------------------\n")
cat(sprintf("%-15s %-15s %-15s %-15s\n", "Variable i", "Variable j", "r²", "R² - r²"))
cat("------------------------------------------------------------\n")

# Détection des colinéarités
colin_detect <- FALSE
colin_paires <- c()
proches_paires <- c()

for(i in 1:4) {
  for(j in 1:4) {
    if(i < j) {
      r2_ij <- mat_cor_carre[i,j]
      var_i <- rownames(mat_cor)[i]
      var_j <- colnames(mat_cor)[j]
      difference <- R2 - r2_ij
      
      cat(sprintf("%-15s %-15s %-15.4f %-15.4f\n", 
                  var_i, var_j, r2_ij, difference))
      
      # Vérification de la colinéarité (r² > R²)
      if(r2_ij > R2) {
        colin_detect <- TRUE
        colin_paires <- c(colin_paires, paste(var_i, "-", var_j, "(r²=", round(r2_ij, 4), ")"))
      } 
      # Vérification de la proximité (alerte si r² > 0.8 * R²)
      else if(r2_ij > 0.8 * R2) {
        proches_paires <- c(proches_paires, paste(var_i, "-", var_j, "(r²=", round(r2_ij, 4), ")"))
      }
    }
  }
}

cat("------------------------------------------------------------\n\n")

# ===========================================
# ÉTAPE 4 : Résumé des paires problématiques
# ===========================================
cat("=========================================\n")
cat("RÉSUMÉ DES CORRÉLATIONS ÉLEVÉES\n")
cat("=========================================\n")

if(length(colin_paires) > 0) {
  cat("\n⚠️ PAIRES AVEC COLINÉARITÉ (r² > R²) :\n")
  for(paire in colin_paires) {
    cat("  • ", paire, "\n")
  }
}

if(length(proches_paires) > 0) {
  cat("\n⚠️ PAIRES AVEC CORRÉLATIONS ÉLEVÉES (r² > 0.8 * R²) :\n")
  for(paire in proches_paires) {
    cat("  • ", paire, "\n")
  }
}

# ===========================================
# CONCLUSION SELON LE TEST DE KLEIN
# ===========================================
cat("\n=========================================\n")
cat("CONCLUSION DU TEST DE KLEIN\n")
cat("=========================================\n")

if(colin_detect) {
  cat("\n❌ PRÉSOMPTION DE COLINÉARITÉ DÉTECTÉE !\n\n")
  cat("Selon la règle de Klein (R² < r²), certaines paires de variables\n")
  cat("sont plus corrélées entre elles que la variable dépendante ne l'est\n")
  cat("avec l'ensemble des prédicteurs. Cela indique une forte colinéarité.\n\n")
  cat("Paires problématiques :\n")
  for(paire in colin_paires) {
    cat("  • ", paire, "\n")
  }
  cat("\nSolutions possibles :\n")
  cat("  1. Supprimer une des variables redondantes\n")
  cat("  2. Combiner les variables colinéaires (ex: moyenne, ACP)\n")
  cat("  3. Utiliser une régression ridge ou lasso\n")
} else if(length(proches_paires) > 0) {
  cat("\n⚠️ COLINÉARITÉ MODÉRÉE À SURVEILLER !\n\n")
  cat("Bien que R² > r² pour toutes les paires, certaines corrélations\n")
  cat("sont très élevées et peuvent causer :\n")
  cat("  • Des erreurs-types gonflées\n")
  cat("  • Des coefficients instables\n")
  cat("  • Des tests de significativité peu fiables\n\n")
  cat("Paires à surveiller :\n")
  for(paire in proches_paires) {
    cat("  • ", paire, "\n")
  }
  cat("\nIl est recommandé de vérifier les VIF (Variance Inflation Factors).\n")
} else {
  cat("\n✓ PAS DE COLINÉARITÉ FORTE selon Klein\n\n")
  cat("Mais cela ne garantit pas l'absence de colinéarité.\n")
  cat("Une analyse complémentaire (VIF) est recommandée.\n")
  cat("  Toutes les r² sont nettement inférieures à R² =", round(R2, 4), "\n")
  cat("  Les variables explicatives sont relativement indépendantes.\n")
}

# ===========================================
# Information supplémentaire : Les plus fortes corrélations
# ===========================================
cat("\n=========================================\n")
cat("INFORMATIONS SUPPLÉMENTAIRES\n")
cat("=========================================\n")

# Trouver les 3 plus fortes corrélations (hors diagonale)
cor_values <- mat_cor
diag(cor_values) <- NA
max_cors <- sort(abs(cor_values), decreasing = TRUE)[1:3]

cat("\nLes 3 plus fortes corrélations absolues entre variables exogènes :\n")
for(k in 1:3) {
  for(i in 1:4) {
    for(j in 1:4) {
      if(i < j && abs(mat_cor[i,j]) == max_cors[k]) {
        cat(sprintf("  %d. %s - %s : |r| = %.4f (r² = %.4f)\n", 
                    k, rownames(mat_cor)[i], colnames(mat_cor)[j], 
                    abs(mat_cor[i,j]), mat_cor[i,j]^2))
      }
    }
  }
}
