library(yaml)
library(dplyr)
library(biomaRt)

# functions ---------------------------------------------------------------
get_data <- function(recipe) {
  message(recipe$dataset)
  mart <- biomaRt::useMart(recipe$biomart, recipe$dataset, recipe$host)
  attr <- unlist(recipe$attributes, use.names = FALSE)
  biomaRt::getBM(attr, mart = mart)
}

tidy_data <- function(df, recipe) {
  dplyr::tbl_df(df) %>%
    dplyr::distinct() %>%
    dplyr::rename_(.dots = recipe$attributes)
}

save_data <- function(..., name) {
  path <- file.path("data/", paste0(name, ".rda"))
  objs <- setNames(list(...), name)
  save(list = name, file = path, envir = list2env(objs), compress = "bzip2")
}

# load recipes ------------------------------------------------------------
recipe.files <- dir("data-raw/recipes", full.names = TRUE)
names(recipe.files) <- sub(".yml", "", basename(recipe.files))
recipes <- lapply(recipe.files, yaml::yaml.load_file)

# gene annotation tables --------------------------------------------------

# download gene tables
genetables <- lapply(recipes, get_data)

# tidy gene tables
genetables <- Map(tidy_data, genetables, recipes)

# export data
Map(save_data, genetables, name = names(genetables))

# transcript 2 gene -------------------------------------------------------
names(recipes) <- paste0(names(recipes), "_tx2gene")

recipes <- lapply(recipes, function(x) {
  x$attributes <- c(
    enstxp = "ensembl_transcript_id",
    ensgene = "ensembl_gene_id")
  return(x)
})

# download tx2gene
tx2gene <- lapply(recipes, get_data)

# tidy tx2gene
tx2gene <- Map(tidy_data, tx2gene, recipes)

# export data
Map(save_data, tx2gene, name = names(tx2gene))
