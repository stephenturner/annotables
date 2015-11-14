
# annotables



Tables for annotating gene lists and converting between identifiers.

## Why?

Many bioinformatics tasks require converting gene identifiers from one convention to another, or annotating gene identifiers with gene symbol, description, position, etc. Sure, [biomaRt](https://bioconductor.org/packages/release/bioc/html/biomaRt.html) dos this for you, but I got tired of remembering biomaRt syntax and hammering Ensembl's servers every time I needed to do this.

This package has basic annotation information from [Ensembl release 82](http://sep2015.archive.ensembl.org/index.html?redirect=no) for:

- Human build 38 (`grch38`)
- Human build 37 (`grch37`)
- Mouse (`grcm38`)
- Rat (`rnor6`)
- Chicken (`galgal4`)
- Worm (`wbcel235`)
- Fly (`bdgp6`)

Where each table contains:

- `ensgene`: Ensembl gene ID
- `entrez`: Entrez gene ID
- `symbol`: Gene symbol
- `chr`: Chromosome
- `start`: Start
- `end`: End
- `strand`: Strand
- `biotype`: Protein coding, pseudogene, mitochondrial tRNA, etc.
- `description`: Full gene name/description.

Additionally, there are tables for human and mouse (`grch38_gt`, `grch37_gt`, and `grcm38_gt`, respectively) that link ensembl gene IDs to ensembl transcript IDs.

## Usage

Installation:


```r
install.packages("devtools")
devtools::install_github("stephenturner/annotables")
```

It isn't necessary to load dplyr, but the tables are `tbl_df` and will print nicely if you have dplyr loaded.


```r
library(dplyr)
library(annotables)
```

Look at the human genes table (note the description column gets cut off because the table becomes too wide to print nicely):


```r
grch38
```

```
## Source: local data frame [66,531 x 9]
## 
##            ensgene entrez  symbol   chr start   end strand        biotype
##              (chr)  (int)   (chr) (chr) (int) (int)  (int)          (chr)
## 1  ENSG00000210049     NA   MT-TF    MT   577   647      1        Mt_tRNA
## 2  ENSG00000211459     NA MT-RNR1    MT   648  1601      1        Mt_rRNA
## 3  ENSG00000210077     NA   MT-TV    MT  1602  1670      1        Mt_tRNA
## 4  ENSG00000210082     NA MT-RNR2    MT  1671  3229      1        Mt_rRNA
## 5  ENSG00000209082     NA  MT-TL1    MT  3230  3304      1        Mt_tRNA
## 6  ENSG00000198888   4535  MT-ND1    MT  3307  4262      1 protein_coding
## 7  ENSG00000210100     NA   MT-TI    MT  4263  4331      1        Mt_tRNA
## 8  ENSG00000210107     NA   MT-TQ    MT  4329  4400     -1        Mt_tRNA
## 9  ENSG00000210112     NA   MT-TM    MT  4402  4469      1        Mt_tRNA
## 10 ENSG00000198763   4536  MT-ND2    MT  4470  5511      1 protein_coding
## ..             ...    ...     ...   ...   ...   ...    ...            ...
## Variables not shown: description (chr)
```

Look at the human genes-to-transcripts table:


```r
grch38_gt
```

```
## Source: local data frame [216,133 x 2]
## 
##            ensgene          enstxp
##              (chr)           (chr)
## 1  ENSG00000210049 ENST00000387314
## 2  ENSG00000211459 ENST00000389680
## 3  ENSG00000210077 ENST00000387342
## 4  ENSG00000210082 ENST00000387347
## 5  ENSG00000209082 ENST00000386347
## 6  ENSG00000198888 ENST00000361390
## 7  ENSG00000210100 ENST00000387365
## 8  ENSG00000210107 ENST00000387372
## 9  ENSG00000210112 ENST00000387377
## 10 ENSG00000198763 ENST00000361453
## ..             ...             ...
```

Tables are `tbl_df`, pipe-able with dplyr:


```r
grch38 %>% 
  filter(biotype=="protein_coding" & chr=="1") %>% 
  select(ensgene, symbol, chr, start, end, description) %>% 
  head %>% 
  pander::pandoc.table(split.table=100, justify="llllll", style="rmarkdown")
```



| ensgene         | symbol   | chr   | start     | end       |
|:----------------|:---------|:------|:----------|:----------|
| ENSG00000158014 | SLC30A2  | 1     | 26037252  | 26046133  |
| ENSG00000173673 | HES3     | 1     | 6244192   | 6245578   |
| ENSG00000243749 | ZMYM6NB  | 1     | 34981535  | 34985353  |
| ENSG00000189410 | SH2D5    | 1     | 20719732  | 20732837  |
| ENSG00000116863 | ADPRHL2  | 1     | 36088875  | 36093932  |
| ENSG00000188643 | S100A16  | 1     | 153606886 | 153613145 |

Table: Table continues below

 

| description                                                                               |
|:------------------------------------------------------------------------------------------|
| solute carrier family 30 (zinc transporter), member 2 [Source:HGNC Symbol;Acc:HGNC:11013] |
| hes family bHLH transcription factor 3 [Source:HGNC Symbol;Acc:HGNC:26226]                |
| ZMYM6 neighbor [Source:HGNC Symbol;Acc:HGNC:40021]                                        |
| SH2 domain containing 5 [Source:HGNC Symbol;Acc:HGNC:28819]                               |
| ADP-ribosylhydrolase like 2 [Source:HGNC Symbol;Acc:HGNC:21304]                           |
| S100 calcium binding protein A16 [Source:HGNC Symbol;Acc:HGNC:20441]                      |


Example with DESeq2 results from the [airway](https://bioconductor.org/packages/release/data/experiment/html/airway.html) package, made tidy with [biobroom](http://www.bioconductor.org/packages/devel/bioc/html/biobroom.html):


```r
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

```
## Source: local data frame [6 x 7]
## 
##              gene    baseMean    estimate   stderror  statistic
##             (chr)       (dbl)       (dbl)      (dbl)      (dbl)
## 1 ENSG00000000003 708.6021697  0.37424998 0.09873107  3.7906000
## 2 ENSG00000000005   0.0000000          NA         NA         NA
## 3 ENSG00000000419 520.2979006 -0.20215550 0.10929899 -1.8495642
## 4 ENSG00000000457 237.1630368 -0.03624826 0.13684258 -0.2648902
## 5 ENSG00000000460  57.9326331  0.08523370 0.24654400  0.3457140
## 6 ENSG00000000938   0.3180984  0.11555962 0.14630523  0.7898530
## Variables not shown: p.value (dbl), p.adjusted (dbl)
```


```r
res_tidy %>% 
  arrange(p.adjusted) %>% 
  head(20) %>% 
  inner_join(grch38, by=c("gene"="ensgene")) %>% 
  select(gene, estimate, p.adjusted, symbol, description) %>% 
  pander::pandoc.table(split.table=100, justify="lrrll", style="rmarkdown")
```



| gene            |   estimate |   p.adjusted | symbol   |
|:----------------|-----------:|-------------:|:---------|
| ENSG00000152583 |     -4.316 |   4.753e-134 | SPARCL1  |
| ENSG00000165995 |     -3.189 |    1.44e-133 | CACNB2   |
| ENSG00000101347 |     -3.618 |   6.619e-125 | SAMHD1   |
| ENSG00000120129 |     -2.871 |   6.619e-125 | DUSP1    |
| ENSG00000189221 |     -3.231 |   9.468e-119 | MAOA     |
| ENSG00000211445 |     -3.553 |    3.94e-107 | GPX3     |
| ENSG00000157214 |     -1.949 |    8.74e-102 | STEAP2   |
| ENSG00000162614 |     -2.003 |    3.052e-98 | NEXN     |
| ENSG00000125148 |     -2.167 |    1.783e-92 | MT2A     |
| ENSG00000154734 |     -2.286 |    4.522e-86 | ADAMTS1  |
| ENSG00000139132 |     -2.181 |    2.501e-83 | FGD4     |
| ENSG00000162493 |     -1.858 |    4.215e-83 | PDPN     |
| ENSG00000162692 |      3.453 |    3.563e-82 | VCAM1    |
| ENSG00000179094 |     -3.044 |    1.199e-81 | PER1     |
| ENSG00000134243 |     -2.149 |     2.73e-81 | SORT1    |
| ENSG00000163884 |     -4.079 |    1.073e-80 | KLF15    |
| ENSG00000178695 |      2.446 |    6.275e-75 | KCTD12   |
| ENSG00000146250 |       2.64 |    1.143e-69 | PRSS35   |
| ENSG00000198624 |     -2.784 |    1.707e-69 | CCDC69   |
| ENSG00000148848 |      1.783 |    1.762e-69 | ADAM12   |

Table: Table continues below

 

| description                                                                                 |
|:--------------------------------------------------------------------------------------------|
| SPARC-like 1 (hevin) [Source:HGNC Symbol;Acc:HGNC:11220]                                    |
| calcium channel, voltage-dependent, beta 2 subunit [Source:HGNC Symbol;Acc:HGNC:1402]       |
| SAM domain and HD domain 1 [Source:HGNC Symbol;Acc:HGNC:15925]                              |
| dual specificity phosphatase 1 [Source:HGNC Symbol;Acc:HGNC:3064]                           |
| monoamine oxidase A [Source:HGNC Symbol;Acc:HGNC:6833]                                      |
| glutathione peroxidase 3 [Source:HGNC Symbol;Acc:HGNC:4555]                                 |
| STEAP family member 2, metalloreductase [Source:HGNC Symbol;Acc:HGNC:17885]                 |
| nexilin (F actin binding protein) [Source:HGNC Symbol;Acc:HGNC:29557]                       |
| metallothionein 2A [Source:HGNC Symbol;Acc:HGNC:7406]                                       |
| ADAM metallopeptidase with thrombospondin type 1 motif, 1 [Source:HGNC Symbol;Acc:HGNC:217] |
| FYVE, RhoGEF and PH domain containing 4 [Source:HGNC Symbol;Acc:HGNC:19125]                 |
| podoplanin [Source:HGNC Symbol;Acc:HGNC:29602]                                              |
| vascular cell adhesion molecule 1 [Source:HGNC Symbol;Acc:HGNC:12663]                       |
| period circadian clock 1 [Source:HGNC Symbol;Acc:HGNC:8845]                                 |
| sortilin 1 [Source:HGNC Symbol;Acc:HGNC:11186]                                              |
| Kruppel-like factor 15 [Source:HGNC Symbol;Acc:HGNC:14536]                                  |
| potassium channel tetramerization domain containing 12 [Source:HGNC Symbol;Acc:HGNC:14678]  |
| protease, serine, 35 [Source:HGNC Symbol;Acc:HGNC:21387]                                    |
| coiled-coil domain containing 69 [Source:HGNC Symbol;Acc:HGNC:24487]                        |
| ADAM metallopeptidase domain 12 [Source:HGNC Symbol;Acc:HGNC:190]                           |

## How?

All the datasets here were collected using biomaRt. The code is below. It should be fairly easy to add new organisms.


```r
library(biomaRt)
library(dplyr)

fix_genes <- . %>% 
  tbl_df %>% 
  distinct %>% 
  rename(ensgene=ensembl_gene_id,
         entrez=entrezgene,
         symbol=external_gene_name,
         chr=chromosome_name,
         start=start_position,
         end=end_position,
         biotype=gene_biotype)

myattributes <- c("ensembl_gene_id",
                  "entrezgene",
                  "external_gene_name",
                  "chromosome_name",
                  "start_position",
                  "end_position",
                  "strand",
                  "gene_biotype",
                  "description")

# Human
grch38 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="hsapiens_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Human grch37
grch37 <- useMart("ENSEMBL_MART_ENSEMBL", 
                  host="grch37.ensembl.org") %>% 
  useDataset(mart=., dataset="hsapiens_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Mouse
grcm38 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="mmusculus_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Rat
rnor6 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="rnorvegicus_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Chicken
galgal4 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="ggallus_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Fly
bdgp6 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="dmelanogaster_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes

# Worm
wbcel235 <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="celegans_gene_ensembl") %>% 
  getBM(mart=., attributes=myattributes) %>% 
  fix_genes
```


```r
fix_txps <- . %>% 
  tbl_df %>% 
  distinct %>% 
  rename(ensgene=ensembl_gene_id,
         enstxp=ensembl_transcript_id)

# Human build 38
grch38_gt <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="hsapiens_gene_ensembl") %>% 
  getBM(mart=., attributes=c("ensembl_gene_id", "ensembl_transcript_id")) %>% 
  fix_txps

# Human build 37
grch37_gt <- useMart("ENSEMBL_MART_ENSEMBL", 
                     host="grch37.ensembl.org") %>% 
  useDataset(mart=., dataset="hsapiens_gene_ensembl") %>% 
  getBM(mart=., attributes=c("ensembl_gene_id", "ensembl_transcript_id")) %>% 
  fix_txps

# Mouse build 38
grcm38_gt <- useMart("ensembl") %>% 
  useDataset(mart=., dataset="mmusculus_gene_ensembl") %>% 
  getBM(mart=., attributes=c("ensembl_gene_id", "ensembl_transcript_id")) 
```


```r
rm(fix_genes, fix_txps, myattributes)
devtools::use_data(grch38)
devtools::use_data(grch37)
devtools::use_data(grcm38)
devtools::use_data(rnor6)
devtools::use_data(galgal4)
devtools::use_data(bdgp6)
devtools::use_data(wbcel235)
devtools::use_data(grch38_gt)
devtools::use_data(grch37_gt)
devtools::use_data(grcm38_gt)
```
