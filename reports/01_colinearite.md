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

![Heatmap](figures/heatmap_color.png)

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
