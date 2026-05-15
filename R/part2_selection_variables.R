# Partie 2 (3.2) — Sélection de variables

# 1. Chargement des données
data(mtcars)

head(mtcars)
str(mtcars)
summary(mtcars)

# 2. Analyse de corrélation
cor_matrix <- cor(mtcars)
print(cor_matrix)

# Visualisation
# install.packages("corrplot")
library(corrplot)
corrplot(cor_matrix, method = "circle")


# 3. Modèle complet

model_full <- lm(mpg ~ ., data = mtcars)
summary(model_full)

# 4. Détection colinéarité (Méthode des signes)
# Corrélations avec la variable cible mpg
cor_target <- cor(mtcars)[,"mpg"]
print(cor_target)

# Coefficients du modèle
coef_model <- coef(model_full)
print(coef_model)

# Comparaison des signes
sign_comparison <- data.frame(
  Variable = names(coef_model)[-1],
  Sign_Coefficient = sign(coef_model[-1]),
  Sign_Correlation = sign(cor_target[names(coef_model)[-1]])
)

print(sign_comparison)

# 5. VIF (Variance Inflation Factor)

# install.packages("car")
library(car)
vif(model_full)

# 6. R² et R² ajusté
r2 <- summary(model_full)$r.squared
r2_adj <- summary(model_full)$adj.r.squared

cat("R² =", r2, "\n")
cat("R² ajusté =", r2_adj, "\n")


# 7. Sélection de variables


# 7.1 Backward
model_backward <- step(model_full, direction = "backward", trace = 0)

# 7.2 Forward
model_null <- lm(mpg ~ 1, data = mtcars)

model_forward <- step(model_null,
                      scope = list(lower = model_null, upper = model_full),
                      direction = "forward",
                      trace = 0)

# 7.3 Stepwise
model_step <- step(model_full, direction = "both", trace = 0)

# 8. Comparaison des modèles
AIC(model_full, model_backward, model_forward, model_step)
BIC(model_full, model_backward, model_forward, model_step)


# 9. Résumé des modèles

summary(model_backward)
summary(model_forward)
summary(model_step)

# 10. VIF du modèle final

vif(model_step)


# 11. Calcul du PRESS

hat_values <- lm.influence(model_step)$hat
residuals_model <- residuals(model_step)

press <- sum((residuals_model / (1 - hat_values))^2)
cat("PRESS =", press, "\n")

# =========================================
# 12. Comparaison SCR vs PRESS
# =========================================
SCR <- sum(residuals_model^2)
cat("SCR =", SCR, "\n")

# =========================================
# 13. Modèle final choisi
# =========================================
summary(model_step)

# ========================================
# 14. Interprétation automatique simple

cat("\nVariables retenues dans le modèle final:\n")
print(names(coef(model_step))[-1])

