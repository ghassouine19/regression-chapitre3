# Partie 3 (3.3 & 3.4) — Corrélation partielle + lien test t

#modèle initial : 
init_modele <- lm(mpg ~ . , data = mtcars)
summary(init_modele)

#corrélation partielle et la selection des variables 
#install.packages("ppcor")
library(ppcor)
library(MASS)
#variable cible et les variables explicative 
Y <- "mpg"
Xvars <- c("cyl","disp","hp","drat","wt",
           "qsec","vs","am","gear","carb")

#correlation simple entre chaque Xj et Y (étape 1)
cors <- sapply(Xvars, function(x)
  cor(mtcars[[Y]], mtcars[[x]])
)
cors
#selection le meilleur 
best_var<-names(which.max(abs(cors)))
best_var
#test de signification de le variable meilleur
cor.test(mtcars[[Y]], mtcars[[best_var]])

#initialisation de les liste 
selected <- c(best_var)
remaining <- setdiff(Xvars, selected)
selected
remaining
#correlation partielle ry,Xj/Xbest (étape 2)
partial_results <- lapply(remaining, function(x){
  
  controls <- mtcars[, selected, drop=FALSE]
  
  test <- pcor.test(
    mtcars[[Y]],
    mtcars[[x]],
    controls
  )
  
  data.frame(
    variable = x,
    partial_cor = test$estimate,
    p_value = test$p.value
  )
})
#transformation en tableau
partial_results <- do.call(rbind, partial_results)
partial_results
#selectionner la meilleur variable 
best_next <- partial_results[
  which.max(abs(partial_results$partial_cor)),
]
best_next
best_next$p_value

#le best_next est significative alors on doit l'ajouter
selected <- c(selected, best_next$variable)
remaining <- setdiff(remaining, best_next$variable)
selected
remaining
#étape 3 :
partial_results <- lapply(remaining, function(x){
  
  controls <- mtcars[, selected, drop=FALSE]
  
  test <- pcor.test(
    mtcars[[Y]],
    mtcars[[x]],
    controls
  )
  
  data.frame(
    variable = x,
    partial_cor = test$estimate,
    p_value = test$p.value
  )
})
partial_results <- do.call(rbind, partial_results)
partial_results
best_next <- partial_results[
  which.max(abs(partial_results$partial_cor)),
]
best_next
best_next$p_value
#on arrète ici car nest_best est non-significative 

#le module finale : 
formula_final <- as.formula(
  paste("mpg ~", paste(selected, collapse = " + "))
)
model_final <- lm(formula_final, data = mtcars)

summary(model_final)

