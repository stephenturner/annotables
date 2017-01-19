library(yaml)
library(dplyr)
library(biomaRt)

# load recipes
recipe.files <- dir("data-raw/recipes", full.names = TRUE)
names(recipe.files) <- sub(".yml", "", basename(recipe.files))

recipes <- lapply(recipe.files, yaml::yaml.load_file)

# download
genetables <- lapply(recipes, function(x) {
  mart <- biomaRt::useMart(x$biomart, x$dataset, x$host)
  attr <- unlist(x$attributes, use.names = FALSE)
  biomaRt::getBM(attr, mart = mart)
})

# tidy
fix_genes <- function(x, recipe) {
  dplyr::tbl_df(x) %>%
    dplyr::distinct() %>%
    dplyr::rename_(.dots = recipe$attributes)
}

genetables <- Map(fix_genes, x = genetables, recipe = recipes)

# export
paths <- file.path("data2", paste0(names(genetables), ".rda"))
envir <- list2env(genetables)

mapply(
  save,
  list = names(genetables),
  file = as.list(paths),
  MoreArgs = list(envir = envir, compress = "bzip2")
)
