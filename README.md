annotables
================

[![DOI](https://zenodo.org/badge/3882/stephenturner/annotables.svg)](https://zenodo.org/badge/latestdoi/3882/stephenturner/annotables)

Provides tables for converting and annotating Ensembl Gene IDs.

Installation
------------

This is an [R](https://www.r-project.org) package.

### [Bioconductor](https://bioconductor.org) method

``` r
source("https://bioconductor.org/biocLite.R")
biocLite("stephenturner/annotables")
```

### [devtools](https://cran.r-project.org/package=devtools) method

``` r
install.packages("devtools")
devtools::install_github("stephenturner/annotables")
```

Rationale
---------

Many bioinformatics tasks require converting gene identifiers from one convention to another, or annotating gene identifiers with gene symbol, description, position, etc. Sure, [biomaRt](https://bioconductor.org/packages/release/bioc/html/biomaRt.html) does this for you, but I got tired of remembering biomaRt syntax and hammering Ensembl's servers every time I needed to do this.

This package has basic annotation information from [Ensembl release 89](http://may2017.archive.ensembl.org/) for:

-   Human build 38 (`grch38`)
-   Human build 37 (`grch37`)
-   Mouse (`grcm38`)
-   Rat (`rnor6`)
-   Chicken (`galgal5`)
-   Worm (`wbcel235`)
-   Fly (`bdgp6`)

Where each table contains:

-   `ensgene`: Ensembl gene ID
-   `entrez`: Entrez gene ID
-   `symbol`: Gene symbol
-   `chr`: Chromosome
-   `start`: Start
-   `end`: End
-   `strand`: Strand
-   `biotype`: Protein coding, pseudogene, mitochondrial tRNA, etc.
-   `description`: Full gene name/description

Additionally, there are `tx2gene` tables that link Ensembl gene IDs to Ensembl transcript IDs.

Usage
-----

``` r
library(annotables)
```

Look at the human genes table (note the description column gets cut off because the table becomes too wide to print nicely):

``` r
grch38
```

    ## # A tibble: 64,101 x 9
    ##            ensgene entrez          symbol              chr     start
    ##              <chr>  <int>           <chr>            <chr>     <int>
    ##  1 ENSG00000252303     NA       RNU6-280P CHR_HG2128_PATCH  67546651
    ##  2 ENSG00000281771     NA           Y_RNA CHR_HG2128_PATCH  67631019
    ##  3 ENSG00000281256     NA    RP11-222G7.2 CHR_HG2191_PATCH  74823667
    ##  4 ENSG00000283272     NA Clostridiales-1 CHR_HG2022_PATCH  91356877
    ##  5 ENSG00000280864     NA   RP11-654C22.2  CHR_HG126_PATCH  72505075
    ##  6 ENSG00000280792     NA   RP11-315F22.1 CHR_HG2233_PATCH 239734956
    ##  7 ENSG00000282878     NA    RP11-399E6.1  CHR_HG986_PATCH  41242373
    ##  8 ENSG00000283276     NA  ABBA01000934.1 CHR_HG2022_PATCH  91374331
    ##  9 ENSG00000281822     NA        RNU1-62P  CHR_HG126_PATCH  72577040
    ## 10 ENSG00000281384     NA      AC093802.1 CHR_HG2233_PATCH 239762860
    ## # ... with 64,091 more rows, and 4 more variables: end <int>,
    ## #   strand <int>, biotype <chr>, description <chr>

Look at the human genes-to-transcripts table:

``` r
grch38_tx2gene
```

    ## # A tibble: 215,929 x 2
    ##             enstxp         ensgene
    ##              <chr>           <chr>
    ##  1 ENST00000516494 ENSG00000252303
    ##  2 ENST00000629583 ENSG00000281771
    ##  3 ENST00000630845 ENSG00000281256
    ##  4 ENST00000636322 ENSG00000283272
    ##  5 ENST00000629165 ENSG00000280864
    ##  6 ENST00000627995 ENSG00000280792
    ##  7 ENST00000635404 ENSG00000282878
    ##  8 ENST00000634566 ENSG00000282878
    ##  9 ENST00000634321 ENSG00000282878
    ## 10 ENST00000636327 ENSG00000283276
    ## # ... with 215,919 more rows

Tables are saved in [tibble](http://tibble.tidyverse.org) format, pipe-able with [dplyr](http://dplyr.tidyverse.org):

``` r
grch38 %>% 
    filter(biotype == "protein_coding" & chr == "1") %>% 
    select(ensgene, symbol, chr, start, end, description) %>% 
    head %>% 
    kable
```

| ensgene         | symbol     | chr |      start|        end| description                                                                                |
|:----------------|:-----------|:----|----------:|----------:|:-------------------------------------------------------------------------------------------|
| ENSG00000117650 | NEK2       | 1   |  211658657|  211675630| NIMA related kinase 2 \[Source:HGNC Symbol;Acc:HGNC:7745\]                                 |
| ENSG00000120341 | SEC16B     | 1   |  177923956|  177984303| SEC16 homolog B, endoplasmic reticulum export factor \[Source:HGNC Symbol;Acc:HGNC:30301\] |
| ENSG00000174567 | GOLT1A     | 1   |  204198160|  204214092| golgi transport 1A \[Source:HGNC Symbol;Acc:HGNC:24766\]                                   |
| ENSG00000278939 | AC242988.1 | 1   |  150302770|  150303291|                                                                                            |
| ENSG00000280316 | AL365181.1 | 1   |  156597173|  156599410|                                                                                            |
| ENSG00000221888 | OR1C1      | 1   |  247757462|  247758406| olfactory receptor family 1 subfamily C member 1 \[Source:HGNC Symbol;Acc:HGNC:8182\]      |

Example with [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) results from the [airway](https://bioconductor.org/packages/release/data/experiment/html/airway.html) package, made tidy with [biobroom](http://www.bioconductor.org/packages/devel/bioc/html/biobroom.html):

``` r
library(DESeq2)
library(airway)

data(airway)
airway <- DESeqDataSet(airway, design = ~cell + dex)
airway <- DESeq(airway)
res <- results(airway)

# tidy results with biobroom
library(biobroom)
res_tidy <- tidy.DESeqResults(res)
head(res_tidy)
```

    ## # A tibble: 6 x 7
    ##              gene    baseMean    estimate  stderror  statistic
    ##             <chr>       <dbl>       <dbl>     <dbl>      <dbl>
    ## 1 ENSG00000000003 708.6021697  0.38125397 0.1006560  3.7876937
    ## 2 ENSG00000000005   0.0000000          NA        NA         NA
    ## 3 ENSG00000000419 520.2979006 -0.20681259 0.1122218 -1.8428915
    ## 4 ENSG00000000457 237.1630368 -0.03792034 0.1434532 -0.2643394
    ## 5 ENSG00000000460  57.9326331  0.08816367 0.2871677  0.3070111
    ## 6 ENSG00000000938   0.3180984  1.37822703 3.4998728  0.3937935
    ## # ... with 2 more variables: p.value <dbl>, p.adjusted <dbl>

``` r
res_tidy %>% 
    arrange(p.adjusted) %>% 
    head(20) %>% 
    inner_join(grch38, by = c("gene" = "ensgene")) %>% 
    select(gene, estimate, p.adjusted, symbol, description) %>% 
    kable
```

| gene            |   estimate|  p.adjusted| symbol  | description                                                                                                           |
|:----------------|----------:|-----------:|:--------|:----------------------------------------------------------------------------------------------------------------------|
| ENSG00000152583 |  -4.574919|           0| SPARCL1 | SPARC like 1 \[Source:HGNC Symbol;Acc:HGNC:11220\]                                                                    |
| ENSG00000165995 |  -3.291062|           0| CACNB2  | calcium voltage-gated channel auxiliary subunit beta 2 \[Source:HGNC Symbol;Acc:HGNC:1402\]                           |
| ENSG00000120129 |  -2.947810|           0| DUSP1   | dual specificity phosphatase 1 \[Source:HGNC Symbol;Acc:HGNC:3064\]                                                   |
| ENSG00000101347 |  -3.766995|           0| SAMHD1  | SAM and HD domain containing deoxynucleoside triphosphate triphosphohydrolase 1 \[Source:HGNC Symbol;Acc:HGNC:15925\] |
| ENSG00000189221 |  -3.353580|           0| MAOA    | monoamine oxidase A \[Source:HGNC Symbol;Acc:HGNC:6833\]                                                              |
| ENSG00000211445 |  -3.730403|           0| GPX3    | glutathione peroxidase 3 \[Source:HGNC Symbol;Acc:HGNC:4555\]                                                         |
| ENSG00000157214 |  -1.976773|           0| STEAP2  | STEAP2 metalloreductase \[Source:HGNC Symbol;Acc:HGNC:17885\]                                                         |
| ENSG00000162614 |  -2.035665|           0| NEXN    | nexilin F-actin binding protein \[Source:HGNC Symbol;Acc:HGNC:29557\]                                                 |
| ENSG00000125148 |  -2.210979|           0| MT2A    | metallothionein 2A \[Source:HGNC Symbol;Acc:HGNC:7406\]                                                               |
| ENSG00000154734 |  -2.345604|           0| ADAMTS1 | ADAM metallopeptidase with thrombospondin type 1 motif 1 \[Source:HGNC Symbol;Acc:HGNC:217\]                          |
| ENSG00000139132 |  -2.228903|           0| FGD4    | FYVE, RhoGEF and PH domain containing 4 \[Source:HGNC Symbol;Acc:HGNC:19125\]                                         |
| ENSG00000162493 |  -1.891217|           0| PDPN    | podoplanin \[Source:HGNC Symbol;Acc:HGNC:29602\]                                                                      |
| ENSG00000134243 |  -2.195712|           0| SORT1   | sortilin 1 \[Source:HGNC Symbol;Acc:HGNC:11186\]                                                                      |
| ENSG00000179094 |  -3.191750|           0| PER1    | period circadian clock 1 \[Source:HGNC Symbol;Acc:HGNC:8845\]                                                         |
| ENSG00000179094 |  -3.191750|           0| PER1    | period circadian clock 1 \[Source:HGNC Symbol;Acc:HGNC:8845\]                                                         |
| ENSG00000162692 |   3.692662|           0| VCAM1   | vascular cell adhesion molecule 1 \[Source:HGNC Symbol;Acc:HGNC:12663\]                                               |
| ENSG00000163884 |  -4.459128|           0| KLF15   | Kruppel like factor 15 \[Source:HGNC Symbol;Acc:HGNC:14536\]                                                          |
| ENSG00000178695 |   2.528174|           0| KCTD12  | potassium channel tetramerization domain containing 12 \[Source:HGNC Symbol;Acc:HGNC:14678\]                          |
| ENSG00000198624 |  -2.918436|           0| CCDC69  | coiled-coil domain containing 69 \[Source:HGNC Symbol;Acc:HGNC:24487\]                                                |
| ENSG00000107562 |   1.911670|           0| CXCL12  | C-X-C motif chemokine ligand 12 \[Source:HGNC Symbol;Acc:HGNC:10672\]                                                 |
| ENSG00000148848 |   1.814543|           0| ADAM12  | ADAM metallopeptidase domain 12 \[Source:HGNC Symbol;Acc:HGNC:190\]                                                   |
