# Contributing — LA PRATIQUE DE LA RÉGRESSION (Chapitre 3)

Merci de contribuer à ce projet. Ce document décrit **les règles essentielles** pour garder une structure propre et faciliter l’intégration.

---

## 1) Organisation des branches

### Branches principales
- `main` : livrable final (stable)
- `dev` : intégration (tout passe par ici avant `main`)

### Branches de travail (une par groupe)
Créer une branche à partir de `dev` :

- Groupe B (3.1 Colinéarité) : `feature/groupe-b`
- Groupe A (3.2 Sélection de variables) : `feature/groupe-a`
- Groupe C (3.3 & 3.4 Corrélation partielle) : `feature/groupe-c`
- Groupe D (3.5 & 3.6 Méthodes avancées) : `feature/groupe-d`

**Règle :** on ne commit jamais directement sur `main`.

---

## 2) Structure et “où modifier quoi”

### Code R (fonctions)
Les fonctions communes et celles par partie se trouvent dans `R/`.

- `R/part1_colinearite.R`
- `R/part2_selection_variables.R`
- `R/part3_correlation_partielle.R`
- `R/part4_methodes_avancees.R`

> Optionnel : si vous créez des fonctions communes, vous pouvez ajouter `R/utils.R`.

### Rapports (texte + résultats)
Chaque partie a un fichier dans `reports/` (format Markdown) :

- `reports/01_colinearite.md`
- `reports/02_selection_variables.md`
- `reports/03_corr_partielle.md`
- `reports/04_methodes_avancees.md`

**Règles :**
- Chaque groupe modifie principalement **son** `R/partX_*.R` et **son** `reports/0X_*.md`.
- Ne pas modifier les fichiers des autres groupes sans discussion.
- Le rapport `.md` doit rester clair : titres, explications, résultats (tableaux/figures si besoin).

---

## 3) Gestion des données

- Données brutes : `data/raw/` (ne pas modifier manuellement les fichiers bruts)
- Données préparées : `data/processed/`

**Règles :**
- Éviter de pousser des fichiers volumineux sur GitHub (ou utiliser Git LFS).
- Si vous modifiez la façon de préparer les données, expliquez-le dans le rapport de votre partie.

---

## 4) Environnement R (renv)

On utilise `renv` pour rendre le projet reproductible.

### Initialisation (une seule fois)
Dans R à la racine du projet :
```r
install.packages("renv")
renv::init()
```

### Après installation de nouveaux packages
Quand vous ajoutez un package (ex: `car`, `ppcor`, `tidyverse`), exécuter :
```r
renv::snapshot()
```

**Règle :** si vous ajoutez une dépendance, le commit doit inclure la mise à jour de `renv.lock`.

---

## 5) Convention de commits

Format conseillé :
- `feat(3.1): ...` (nouvelle fonctionnalité)
- `fix: ...` (correction)
- `docs: ...` (rapport/documentation)
- `chore: ...` (maintenance)

Exemples :
- `feat(3.2): add forward/backward selection functions`
- `docs(3.1): add explanation and VIF interpretation`

---

## 6) Pull Requests (PR)

Avant d’ouvrir une PR vers `dev`, vérifier :

### Checklist PR
- [ ] Le code R s’exécute sans erreur (scripts testés dans RStudio)
- [ ] Le fichier `reports/*.md` est mis à jour (explications + résultats)
- [ ] Pas de gros fichiers inutiles ajoutés (outputs, données énormes)
- [ ] Pas de modifications non nécessaires dans les fichiers des autres groupes

### Cible des PR
- PR des branches `feature/...` → `dev`
- PR finale `dev` → `main` (par le responsable d’intégration)

---

## 7) Règles de style (simples)

- Utiliser des noms explicites : `compute_vif()`, `partial_f_test()`, etc.
- Mettre la logique dans `R/` et garder `reports/` pour l’explication + résultats.
- Commentaires courts mais utiles dans les scripts R.

---

## 8) Conflits de merge

En cas de conflit :
1. Mettre à jour votre branche avec `dev`
2. Résoudre le conflit localement (ne pas supprimer du contenu sans vérifier)
3. Tester votre script R
4. Re-push et demander review