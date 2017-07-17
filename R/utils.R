# Generate annotable documentation based on recipe
document_annotable <- function(x, table, type) {
  type <- match.arg(type, c("gene", "tx2gene"))
  template.path <- system.file("inst/templates",
                               paste0(type, ".R"),
                               package = "annotables",
                               mustWork = TRUE)

  table.path <- system.file("data", paste0(table, ".rda"),
                            package = "annotables")
  stopifnot(file.exists(table.path))

  file.path <- file.path("R", paste0(table, ".R"))

  data <- list(
    table = table,
    assembly = sub("_TX2GENE", "", toupper(table)),
    name = x$name,
    species = x$species,
    attributes = names(x$attributes),
    path = sub(" ", "_", tolower(x$species))
  )

  rendered <- whisker::whisker.render(readLines(template.path), data)
  # workaround for github.com/edwindj/whisker/issues/20
  rendered <- gsub("(\\{) | (\\})", "\\1\\2", rendered)

  writeLines(rendered, file.path)
}
