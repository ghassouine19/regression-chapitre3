# Interprétation du modèle de régression multiple initial

Dans un premier temps, un modèle de régression multiple a été construit en intégrant l’ensemble des variables explicatives disponibles afin d’évaluer leur influence sur la variable dépendante.

Le modèle obtenu présente les résultats suivants :

- Residual Standard Error = 2.65
- Multiple R-squared = 0.869
- F-statistic = 13.93
- p-value = \(3.793 \times 10^{-7}\)

# Qualité globale du modèle

Le coefficient de détermination \(R^2 = 0.869\) indique que le modèle explique environ \(86.9\%\) de la variabilité de la variable réponse. Cette valeur élevée montre que les variables explicatives incluses dans le modèle décrivent correctement le phénomène étudié.

Le test global de Fisher donne une statistique :

\[
F = 13.93
\]

avec une p-value très faible :

\[
p = 3.793 \times 10^{-7}
\]

Cette p-value étant largement inférieure au seuil de signification classique de \(5\%\), le modèle est globalement significatif. On rejette donc l’hypothèse nulle selon laquelle toutes les variables explicatives auraient simultanément des coefficients nuls.

Autrement dit, au moins une des variables explicatives contribue significativement à l’explication de la variable dépendante.

# Analyse de l’erreur résiduelle

L’erreur standard résiduelle (Residual Standard Error) vaut :

\[
RSE = 2.65
\]

Cette mesure représente l’écart moyen entre les valeurs observées et les valeurs prédites par le modèle. Une valeur relativement faible de cette erreur indique que les prédictions du modèle sont proches des données réelles, ce qui traduit une bonne précision globale.

Les \(21\) degrés de liberté restants correspondent au nombre d’observations disponibles après estimation des paramètres du modèle.

# Transition vers les corrélations partielles et la sélection des variables

Malgré les bonnes performances globales du modèle, l’introduction de toutes les variables explicatives peut entraîner certains problèmes tels que :

- la présence de variables peu significatives ;
- la redondance d’information entre variables ;
- des phénomènes de multicolinéarité ;
- une complexité excessive du modèle.

Il devient donc nécessaire d’étudier les corrélations partielles ainsi que la significativité individuelle des variables afin d’identifier les variables les plus pertinentes et de construire un modèle plus simple, plus stable et plus interprétable.

# Correlation partielle et selections des variables

## Etape 1 : Analyse des corrélations et sélection de la première variable

Les coefficients de corrélation entre la variable réponse et les différentes variables explicatives montrent que plusieurs variables présentent une forte relation avec la variable à expliquer.

La variable `wt` (weight) possède la corrélation absolue la plus élevée :

\[
cor(Y, wt) = -0.8676594
\]

Cette forte corrélation négative indique que lorsque le poids du véhicule augmente, la variable réponse diminue fortement. La relation entre les deux variables est donc importante et inverse.

Le test de corrélation de Pearson associé donne les résultats suivants :

\[
t = -9.559
\]

avec une p-value :

\[
p = 1.294 \times 10^{-10}
\]

Cette p-value étant largement inférieure au seuil de \(5\%\), la corrélation entre la variable réponse et `wt` est statistiquement significative.

Ainsi, la variable `wt` a été sélectionnée comme première variable explicative dans le processus de sélection des variables.

Après cette étape, les variables restantes candidates pour l’ajout au modèle sont :

- cyl
- disp
- hp
- drat
- qsec
- vs
- am
- gear
- carb

Cette première sélection permet de construire progressivement un modèle plus pertinent en ajoutant uniquement les variables apportant une information complémentaire significative.

## Etape 2 : Analyse des corrélations partielles et sélection de la deuxième variable

Après la sélection de la variable `wt`, les corrélations partielles ont été calculées afin de mesurer la relation entre la variable réponse et chacune des variables restantes, tout en contrôlant l’effet de `wt`.

Les résultats obtenus montrent que certaines variables conservent une relation significative avec la variable réponse même après prise en compte de l’effet du poids du véhicule.

La variable présentant la corrélation partielle absolue la plus élevée est :

\[
cor_{partiel}(Y, cyl \mid wt) = -0.5595771
\]

Cette corrélation négative indique qu’après élimination de l’effet de `wt`, la variable `cyl` reste fortement liée à la variable réponse.

Le test de significativité associé donne une p-value :

\[
p = 0.001064282
\]

Cette valeur étant inférieure au seuil de signification de \(5\%\), la variable `cyl` est considérée comme statistiquement significative.

Par conséquent, la variable `cyl` a été ajoutée au modèle comme deuxième variable explicative.

Les variables déjà sélectionnées sont alors :

- wt
- cyl

Les variables restantes candidates pour les étapes suivantes sont :

- disp
- hp
- drat
- qsec
- vs
- am
- gear
- carb

Cette étape montre que la variable `cyl` apporte une information complémentaire importante au modèle, même après prise en compte de la variable `wt`.

## Etape 3 : Arrêt du processus de sélection des variables

Après l’ajout des variables `wt` et `cyl`, de nouvelles corrélations partielles ont été calculées afin d’évaluer l’apport des variables restantes au modèle.

Les résultats montrent que la variable ayant la plus grande corrélation partielle en valeur absolue est :

\[
cor_{partiel}(Y, hp \mid wt, cyl) = -0.2758932
\]

Cependant, le test de significativité associé donne une p-value :

\[
p = 0.1400152
\]

Cette valeur étant supérieure au seuil de signification de \(5\%\), la variable `hp` n’est pas statistiquement significative après prise en compte des variables déjà sélectionnées.

Ainsi, aucune des variables restantes n’apporte une contribution suffisamment significative au modèle. Le processus de sélection est donc arrêté à cette étape.

Le modèle final retenu contient alors les variables explicatives suivantes :

- wt
- cyl

Ce résultat indique que ces deux variables suffisent à expliquer une grande partie de la variabilité de la variable réponse, tandis que les autres variables n’apportent pas d’information complémentaire significative.

## Interprétation du modèle final sélectionné

Après le processus de sélection des variables basé sur les corrélations partielles, le modèle final retenu contient les variables explicatives `wt` et `cyl`.

L’équation estimée du modèle est :

\[
\hat{Y} = 39.6863 - 3.1910 \times wt - 1.5078 \times cyl
\]

### Interprétation des coefficients

Le coefficient associé à la variable `wt` est négatif :

\[
\beta_{wt} = -3.1910
\]

Cela signifie qu’une augmentation d’une unité du poids du véhicule entraîne en moyenne une diminution de la variable réponse de \(3.1910\) unités, toutes choses égales par ailleurs.

Le coefficient associé à la variable `cyl` est également négatif :

\[
\beta_{cyl} = -1.5078
\]

Ainsi, une augmentation du nombre de cylindres entraîne une diminution moyenne de la variable réponse de \(1.5078\) unités lorsque les autres variables restent constantes.

Les deux variables présentent des p-values très faibles :

- `wt` : \(p = 0.000222\)
- `cyl` : \(p = 0.001064\)

Ces valeurs étant inférieures au seuil de \(5\%\), les deux variables sont statistiquement significatives dans le modèle final.

### Qualité globale du modèle finale

Le coefficient de détermination est :

\[
R^2 = 0.8302
\]

Cela signifie que le modèle explique environ \(83.02\%\) de la variabilité de la variable réponse.

Le coefficient ajusté :

\[
R^2_{adj} = 0.8185
\]

reste également élevé, ce qui confirme la bonne qualité du modèle malgré le nombre réduit de variables explicatives.

Le test global de Fisher donne :

\[
F = 70.91
\]

avec une p-value :

\[
p = 6.809 \times 10^{-12}
\]

Cette très faible p-value montre que le modèle est globalement hautement significatif.

Enfin, l’erreur standard résiduelle vaut :

\[
RSE = 2.568
\]

Cette valeur relativement faible indique que les prédictions obtenues par le modèle sont proches des valeurs observées.

Ainsi, le modèle final obtenu est à la fois simple, interprétable et performant.
