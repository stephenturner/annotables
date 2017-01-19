library(yaml)
library(dplyr)
library(biomaRt)

# load recipes
recipe.files <- dir("data-raw/recipes", full.names = TRUE)
names(recipe.files) <- sub(".yml", "", basename(recipe.files))
recipes <- lapply(recipe.files, yaml::yaml.load_file)


# gene annotation tables --------------------------------------------------

# download gene tables
genetables <- lapply(recipes, function(x) {
  message(x$dataset)
  mart <- biomaRt::useMart(x$biomart, x$dataset, x$host)
  attr <- unlist(x$attributes, use.names = FALSE)
  biomaRt::getBM(attr, mart = mart)
})

# tidy gene tables
fix_genes <- function(x, recipe) {
  dplyr::tbl_df(x) %>%
    dplyr::distinct() %>%
    dplyr::rename_(.dots = recipe$attributes)
}
genetables <- Map(fix_genes, x = genetables, recipe = recipes)
genetables

# export
(paths_genetables <- file.path("data", paste0(names(genetables), ".rda")))
envir_genetables <- list2env(genetables)
mapply(
  save,
  list = names(genetables),
  file = as.list(paths_genetables),
  MoreArgs = list(envir = envir_genetables, compress = "bzip2")
)


# transcript 2 gene -------------------------------------------------------

# download tx2gene
tx2gene <- lapply(recipes, function(x) {
  message(x$dataset)
  mart <- biomaRt::useMart(x$biomart, x$dataset, x$host)
  attr <- c("ensembl_transcript_id", "ensembl_gene_id")
  biomaRt::getBM(attr, mart = mart)
})

# tidy tx2gene
fix_txps <- function(x) {
  x %>%
    dplyr::tbl_df() %>%
    dplyr::distinct() %>%
    dplyr::rename(enstxp=ensembl_transcript_id,
                  ensgene=ensembl_gene_id)
}
tx2gene <- lapply(tx2gene, fix_txps)
tx2gene
names(tx2gene) <- paste0(names(tx2gene), "_tx2gene")

# export
(paths_tx2gene <- file.path("data", paste0(names(tx2gene), ".rda")))
envir_tx2gene <- list2env(tx2gene)
mapply(
  save,
  list = names(tx2gene),
  file = as.list(paths_tx2gene),
  MoreArgs = list(envir = envir_tx2gene, compress = "bzip2")
)

