# 📊 Projet : Régression et sélection de variables

---

## 📌 Chapitre 3.2 : Traitement de la colinéarité

## 🔹 Introduction

Dans ce chapitre, on s’intéresse principalement à la sélection de variables. L’objectif est d’identifier un sous-ensemble de variables explicatives pertinentes et peu redondantes. Deux questions se posent alors : combien de variables retenir et lesquelles choisir.

Deux questions principales :

- Combien de variables retenir ?
- Quelles variables choisir ?

---

## 🔹 3.2.1. Critères d'information et de validation pour la sélection de modèles

### 📈 Coefficient de détermination R²

---

Le coefficient de détermination classique, défini par la relation R² = 1 - (SCR / SCT) (où SCR représente la somme des carrés résiduels et SCT la somme des carrés totaux), constitue l'indicateur usuel de la qualité d'ajustement d'un modèle. Toutefois, ce dernier présente une limite méthodologique majeure : sa valeur est mécaniquement croissante (ou au mieux constante) avec l'adjonction de nouvelles variables explicatives, quand bien même ces dernières seraient dépourvues de lien statistique avec la variable dépendante Y.

R̄² = 1 - [ (SCR / (n - q - 1)) / (SCT / (n - 1)) ] = 1 - ( (n - 1) / (n - q - 1) ) (1 - R²)
R² mesure la qualité d’ajustement du modèle :
⚠️ Problème : augmente toujours avec plus de variables

Dans cette expression, n désigne le nombre d'observations et q représente le nombre de variables exogènes (hors constante). Contrairement au coefficient standard, le R̄² ne progresse que si l'amélioration du pouvoir explicatif (R²) est suffisamment significative pour compenser la perte d'un degré de liberté.

### 📊Application sur données MTCARS :

---

Le coefficient de détermination R2R^2R2 obtenu pour le modèle est égal à 0.8497, ce qui signifie que le modèle explique environ 84.97 % de la variabilité de la variable dépendante, à savoir la consommation en carburant (mpg). Cela indique une très bonne qualité d’ajustement, puisque la majorité de l’information contenue dans les données est capturée par les variables explicatives retenues, à savoir le poids (wt), le temps d’accélération (qsec) et le type de transmission (am). Toutefois, le R2R^2R2 présente une limite importante, car il tend à augmenter systématiquement avec l’ajout de nouvelles variables, même si celles-ci ne sont pas pertinentes. C’est pourquoi on considère également le coefficient de détermination ajusté, dont la valeur est de 0.8336. Celui-ci tient compte du nombre de variables dans le modèle et pénalise l’ajout de variables inutiles. Dans notre cas, la faible différence entre R2R^2R2 et R2R^2R2 ajusté indique que les variables sélectionnées sont pertinentes et que le modèle ne souffre pas de surajustement. Ainsi, ces résultats confirment la robustesse et la fiabilité du modèle estimé.

---

## 🔹 3.2.2 Critères d’information

### 📌 AIC et BIC

AIC = n _ ln(SCR / n) + 2(q + 1)
BIC = n _ ln(SCR / n) + ln(n)(q + 1)

✔️ Plus la valeur est faible → meilleur modèle  
✔️ BIC pénalise plus que AIC

---

## 🔹 3.2.3 Validation croisée (PRESS)

PRESS = Σ (yᵢ - ŷᵢ(-i))²

✔️ Évalue la capacité de prédiction  
✔️ Basé sur "leave-one-out"

---

## 🔹 3.2.4 Méthodes de sélection

### 🔼 Forward Selection

- Commence avec modèle vide
- Ajoute variables une par une

**Résultat :**

- Variables : `wt`, `cyl`, `hp`
- AIC = 155.48
- R² = 0.843

---

### 🔽 Backward Elimination

- Commence avec modèle complet
- Supprime variables inutiles

**Résultat :**

- Variables : `wt`, `qsec`, `am`
- AIC = 154.12
- R² = 0.850

---

### 🔄 Stepwise

- Combine Forward + Backward

**Résultat :**

- Variables : `wt`, `qsec`, `am`

---

## ⚖️ Comparaison des modèles

| Méthode  | Variables    | AIC    | R²    |
| -------- | ------------ | ------ | ----- |
| Forward  | wt, cyl, hp  | 155.48 | 0.843 |
| Backward | wt, qsec, am | 154.12 | 0.850 |
| Stepwise | wt, qsec, am | 154.12 | 0.850 |

---

## ✅ Choix final du modèle

👉 Modèle retenu : **wt + qsec + am**

### ✔️ Raisons :

- Meilleur AIC & BIC
- R² ajusté élevé
- Pas de colinéarité
- Variables significatives
- Interprétation claire

---

## 📎 Conclusion

Le modèle sélectionné offre un bon compromis entre performance et simplicité, avec une excellente capacité de généralisation.
