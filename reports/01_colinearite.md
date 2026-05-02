title: "3.1 — Détection de la colinéarité"

## Introduction

En régression linéaire multiple, on cherche à établir une relation entre des variables explicatives (exogènes) et une variable à expliquer (endogène). Dans l'idéal, chaque variable apporte une information unique.

Mais dans la pratique, certaines variables sont fortement corrélées. C'est la **colinéarité**.

**Problèmes causés :**
- Coefficients instables et difficiles à interpréter
- Masquage de l'effet de certaines variables
- Risque d'éliminer à tort des variables importantes

Nous utilisons la base **mtcars** (32 voitures) avec :
- `mpg` : consommation (endogène)
- `hp` : puissance, `wt` : poids, `disp` : cylindrée, `drat` : rapport de pont

---

## Définition

On parle de colinéarité lorsque deux variables explicatives ont une corrélation élevée (|r| > 0,8).

---

## Résultats sur mtcars

**Matrice des corrélations (exogènes uniquement) :**

| Variable | hp | wt | disp | drat |
|----------|-----|-----|------|------|
| hp | 1.00 | 0.66 | 0.79 | -0.45 |
| wt | 0.66 | 1.00 | 0.89 | -0.71 |
| disp | 0.79 | 0.89 | 1.00 | -0.71 |
| drat | -0.45 | -0.71 | -0.71 | 1.00 |

**Observations :**
- `wt` et `disp` : 0,89 (> 0,8) → colinéarité sévère
- `disp` et `hp` : 0,79 (proche du seuil) → colinéarité suspectée

![Heatmap](figures/65b9ac66-06e6-45b3-8044-51b69104aa47.png)

---

## Les 4 conséquences principales

| # | Conséquence | Exemple sur mtcars |
|---|-------------|---------------------|
| 1 | Signes contradictoires | `disp` : corrélation négative avec mpg (-0,85) mais coefficient positif dans la régression |
| 2 | Variances gonflées | Les estimateurs deviennent instables (VIF élevé, vu en 3.1.3) |
| 3 | Coefficients non significatifs | `drat` a un sens mécanique mais p-value souvent élevée |
| 4 | Instabilité des résultats | Les coefficients changent selon l'échantillon |

---

## Pourquoi c'est un problème

- On ne peut plus dire **"toutes choses égales par ailleurs"**
- On risque d'**éliminer à tort** des variables importantes
- Les **tests de significativité** deviennent peu fiables

➡️ **Avant toute interprétation, il faut détecter la colinéarité (sections 3.1.2 et 3.1.3).**

---
## Code R utilisé
Le script complet est dans R/part1_colinearite.R.




## Test de Klein pour la détection de la colinéarité

### Principe du test

Le test de Klein compare le coefficient de détermination du modèle global \(R^2\) avec les carrés des corrélations entre variables explicatives \(r^2_{x_i x_j}\). La règle est la suivante :

- Si \( r^2_{x_i x_j} > R^2 \) → **colinéarité forte** détectée  
- Si \( r^2_{x_i x_j} \) est proche de \( R^2 \) → **colinéarité modérée** à surveiller  

---

### Mise en œuvre dans R

    # TEST DE KLEIN POUR DÉTECTER LA COLINÉARITÉ

    # Régression multiple
    regression <- lm(mpg ~ hp + wt + disp + drat, data = mtcars)
    R2 <- summary(regression)$r.squared

    # Matrice des corrélations entre exogènes
    mat_cor <- cor(mtcars[, c("hp", "wt", "disp", "drat")])
    mat_cor_carre <- mat_cor^2

    # Affichage des résultats
    cat("R² du modèle global =", round(R2, 4), "\n\n")
    cat("Matrice des r² entre exogènes :\n")
    print(round(mat_cor_carre, 4))

    # Comparaison R² vs r²
    cat("\nComparaison détaillée :\n")
    for(i in 1:4) {
      for(j in 1:4) {
        if(i < j) {
          r2_ij <- mat_cor_carre[i,j]
          var_i <- rownames(mat_cor)[i]
          var_j <- colnames(mat_cor)[j]
          diff <- R2 - r2_ij
          cat(var_i, "-", var_j, ": r² =", round(r2_ij, 4), 
              "| R² - r² =", round(diff, 4), "\n")
        }
      }
    }

---

### Interprétation

Aucune paire de variables n’a un \( r^2 \) supérieure au \( R^2 \) (0,8376). Selon le critère de Klein, il n’y a donc pas de colinéarité forte.

Cependant, la paire *wt* (poids) et *disp* (cylindrée) présente un \( r^2 = 0,7885 \), très proche du \( R^2 \) global (différence de seulement 0,0491). Cette forte corrélation (\( r = 0,888 \)) est préoccupante car :

- Les deux variables mesurent des concepts similaires (taille du véhicule)  
- Des erreurs-types gonflées peuvent rendre les coefficients instables  
- La significativité individuelle des variables peut être sous-estimée  

Ce diagnostic est renforcé par le conflit de signe observé pour la variable *disp*, ce qui confirme l’instabilité des coefficients due à la colinéarité.

---

### Conclusion du test de Klein

Le test de Klein révèle une colinéarité modérée à surveiller entre les variables *wt* et *disp*. Bien que le seuil strict ne soit pas atteint, la proximité entre \( r^2 \) et \( R^2 \) indique un risque réel de multicolinéarité.

---

### Limites du test de Klein

- Le test n’est pas un test statistique formel (pas de p-value, pas de seuil universel)  
- Il ne détecte que la colinéarité par paires  
- Une colinéarité multiple peut ne pas être détectée  
- Si \( r^2 > R^2 \), cela indique une très forte colinéarité  

---

### Recommandations

- Calculer les facteurs d’inflation de la variance (VIF) pour confirmer le diagnostic  
- Envisager de supprimer une variable redondante (*wt* ou *disp*)  
- Utiliser une régression ridge pour stabiliser le modèle  
