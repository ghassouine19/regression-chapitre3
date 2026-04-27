# LA PRATIQUE DE LA RÉGRESSION — Chapitre 3

## Objectif
Implémenter et illustrer les notions du Chapitre 3 :
- (3.1) Détection de la colinéarité
- (3.2) Traitement et sélection de variables
- (3.3 & 3.4) Corrélation partielle + lien avec test t de Student
- (3.5 & 3.6) Méthodes avancées

## Structure
- `R/` : scripts et fonctions R par partie
- `reports/` : rapports en Markdown (explications + résultats)
- `data/raw/` : données brutes
- `data/processed/` : données préparées
- `renv.lock` : dépendances R (reproductibilité)

## Branches
- `main` : livrable final stable
- `dev` : intégration
- `feature/groupe-a`
- `feature/groupe-b`
- `feature/groupe-c`
- `feature/groupe-d`

## Comment exécuter (RStudio)
1. Ouvrir le dossier du projet (ou le fichier `.Rproj`)
2. Initialiser `renv` (une seule fois) :
   ```r
   install.packages("renv")
   renv::init()
   ```
3. Ouvrir un script dans `R/` et exécuter les commandes (Run) pour obtenir les résultats
4. Reporter les résultats/interprétations dans `reports/*.md`

## Répartition
- Groupe B : `reports/01_colinearite.md` + `R/part1_colinearite.R`
- Groupe A : `reports/02_selection_variables.md` + `R/part2_selection_variables.R`
- Groupe C : `reports/03_corr_partielle.md` + `R/part3_correlation_partielle.R`
- Groupe D : `reports/04_methodes_avancees.md` + `R/part4_methodes_avancees.R`