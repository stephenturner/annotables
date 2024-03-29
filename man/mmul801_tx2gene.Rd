% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mmul801_tx2gene.R
\docType{data}
\name{mmul801_tx2gene}
\alias{mmul801_tx2gene}
\title{Macaque transcripts to genes}
\format{
An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 64228 rows and 2 columns.
}
\source{
\url{http://ensembl.org/macaca_mulatta}
}
\usage{
mmul801_tx2gene
}
\description{
Lookup table for converting Macaque (\emph{Macaca mulatta})
Ensembl transcript IDs to gene IDs based on genome assembly
MMUL801 from Ensembl.
}
\details{
Variables:
\itemize{
\item enstxp
\item ensgene
}
}
\examples{
head(mmul801_tx2gene)
}
\keyword{datasets}
