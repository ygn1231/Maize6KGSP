# Maize6KGSP

## 🌽 Maize6K-GS Array-Based Genomic Prediction Platform

<p align="center">
  <img src="inst/www/fig2.png" width="760" alt="Maize6KGSP graphical user interface">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.1-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/R-%3E%3D%204.1.0-276DC3.svg" alt="R version">
  <img src="https://img.shields.io/badge/GUI-Shiny-75AADB.svg" alt="Shiny GUI">
  <img src="https://img.shields.io/badge/license-GPL--3-green.svg" alt="License">
</p>

`Maize6KGSP` is an R package with a Shiny-based graphical user interface (GUI) developed for the **Maize6K-GS array**. It provides an integrated workflow for genotype processing, F1 hybrid genotype inference, genomic prediction model evaluation, hybrid performance prediction, and phenotype prediction in maize breeding populations.

The GUI is designed for routine genomic-selection analyses and allows users to complete the main analytical steps without writing R code.

## Contents

- [Overview](#overview)
- [Documentation](#documentation)
- [Installation](#installation)
- [Launch Maize6KGSP](#launch-maize6kgsp)
- [Package dependencies](#package-dependencies)
- [Example datasets](#example-datasets)
- [Input data](#input-data)
- [GUI modules and usage](#gui-modules-and-usage)
- [Genomic selection models](#genomic-selection-models)
- [Output](#output)
- [GUI implementation](#gui-implementation)
- [FAQ](#faq)
- [Citation](#citation)
- [Contact](#contact)
- [License](#license)

## Overview

The current GUI contains seven modules:

| Module | Main function |
|:--|:--|
| **home** | Platform overview and navigation |
| **convert** | Genotype format conversion, marker QC, and optional missing-genotype imputation |
| **infergen** | F1 hybrid genotype inference from parental genotypes |
| **geno_int** | Genotype harmonization between training and breeding populations |
| **cv** | Cross-validation-based evaluation of genomic prediction models |
| **hybrid_predict** | Prediction and ranking of potential hybrid combinations |
| **phenotype_predict** | Phenotype prediction for target inbred or hybrid populations |

### Main features

- Supports HapMap single-bit, HapMap double-bit, VCF, and numeric genotype matrices.
- Performs marker-level quality control using missing-rate and minor-allele-frequency thresholds.
- Supports optional missing-genotype imputation.
- Infers F1 hybrid genotypes from parental inbred lines.
- Harmonizes genotype datasets from training and prediction populations.
- Evaluates six genomic prediction models by cross-validation.
- Predicts and ranks untested hybrid combinations.
- Predicts phenotypes of target inbred or hybrid populations.
- Provides an interactive Shiny GUI for routine analyses.

## Documentation

A detailed graphical user manual with step-by-step instructions and screenshots is provided in the repository:

- **User manual (PDF):** [`docs/Maize6KGSP_User_Manual.pdf`](docs/Maize6KGSP_User_Manual.pdf)
- **Editable manual (DOCX):** [`docs/Maize6KGSP_User_Manual.docx`](docs/Maize6KGSP_User_Manual.docx)

The manual covers installation, GUI launch, input-file requirements, genotype conversion, quality control, hybrid genotype inference, genotype integration, cross-validation, hybrid prediction, and phenotype prediction.

## Installation

### Option 1: Install directly from GitHub

`Maize6KGSP` requires **R >= 4.1.0**. RStudio is recommended but is not required.

```r
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
}

devtools::install_github("ygn1231/Maize6KGSP", force = TRUE)
```

### Option 2: Clone the repository and install locally

```bash
git clone https://github.com/ygn1231/Maize6KGSP.git
```

Then, in R:

```r
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
}

devtools::install_local("Maize6KGSP", force = TRUE)
```

## Launch Maize6KGSP

After installation, launch the graphical interface with:

```r
library(Maize6KGSP)
Maize6KGSP.GUI()
```

The interface opens in the default web browser or the RStudio Viewer, depending on the local R environment.

## Package dependencies

The current package imports the following R packages:

```text
BGLR
glmnet
xgboost
pls
data.table
doParallel
foreach
shiny
DT
utils
```

These dependencies are declared in the package `DESCRIPTION` file and are normally installed automatically when `Maize6KGSP` is installed from GitHub.

If a dependency must be installed manually, use for example:

```r
install.packages(c(
    "BGLR", "glmnet", "xgboost", "pls", "data.table",
    "doParallel", "foreach", "shiny", "DT"
))
```

## Example datasets

The repository includes example files corresponding to the main input types used by the GUI:

| File | Data type | Main module(s) |
|:--|:--|:--|
| `train_inbred.hmp.txt` | Training/reference inbred genotype data (HapMap) | `convert`, `geno_int`, `hybrid_predict`, `phenotype_predict` |
| `test_inbred.hmp.txt` | Target/breeding-population inbred genotype data (HapMap) | `convert`, `geno_int`, `phenotype_predict` |
| `train_inbredphe.csv` | Individual-level phenotype data for a training/reference population | `cv`, `phenotype_predict` |
| `train_hybridphe.csv` | Hybrid phenotype data with two parental IDs and a target trait | `cv`, `hybrid_predict` |
| `test_crosses_id.csv` | Two-column parental combinations for target crosses | `infergen` |

The example files can be used directly to become familiar with the corresponding modules. Sample IDs and marker IDs must remain consistent among files that are used together.

## Input data

The input requirements below correspond directly to the files and fields used in the GUI and in the User Manual.

### Input requirements by module

| Module | Required input | Optional/reusable input |
|:--|:--|:--|
| `convert` | One genotype file | — |
| `infergen` | Parental inbred genotype data + a two-column cross file | Genotype output from `convert` can be reused |
| `geno_int` | Training/reference genotype data + target/breeding genotype data | — |
| `cv` | Genotype data + phenotype data for the same individuals/hybrids | Hybrid genotype output from `infergen` can be reused |
| `hybrid_predict` | Parental inbred genotype data + hybrid phenotype training data | Genotype output from `convert` can be reused |
| `phenotype_predict` | Training/reference genotype data + target/breeding genotype data + training phenotype data | Matched `train_geno` and `breed_geno` from `geno_int` can be reused |

### 1. Genotype data

The `convert` and `geno_int` modules accept four genotype input types:

1. **HapMap single-bit**
2. **HapMap double-bit**
3. **VCF**
4. **Numeric genotype matrix**

For HapMap and VCF input, standard marker and sample information should be retained. After conversion, Maize6KGSP uses a numeric genotype matrix in which rows represent individuals and columns represent markers.

Example HapMap double-bit genotype data (`train_inbred.hmp.txt`):

```text
rs#         alleles  chrom  pos      strand  assembly#  center  protLSID  assayLSID  panelLSID  QCcode  Y10  Y152  Y171  Y221
1_564041    C/G      1      564041   +       NA         NA      NA        NA         NA         NA      CC   CC    CC    CG
1_564313    T/C      1      564313   +       NA         NA      NA        NA         NA         NA      CC   CC    CC    TT
1_1837808   G/A      1      1837808  +       NA         NA      NA        NA         NA         NA      GG   GG    GG    AA
1_1921450   C/T      1      1921450  +       NA         NA      NA        NA         NA         NA      CC   CC    CC    CC
```

The first 11 columns contain standard HapMap marker information, followed by genotype calls for each sample. The example above is a shortened excerpt of the provided `train_inbred.hmp.txt` file.

Marker-level quality-control options in `convert` include marker missing rate, minor allele frequency (MAF), and optional missing-genotype imputation.

> **Important:** Sample IDs and marker identifiers must be consistent across genotype, phenotype, and crossing files that are analyzed together.

### 2. Individual phenotype data

Individual-level phenotype data are used when one phenotypic value corresponds directly to each row of a genotype matrix, for example in `cv` or `phenotype_predict`. The phenotype input is a **single numeric trait vector**, and the sample identifiers (stored as row names/record names in the input file) must correspond to the row names of the training/reference genotype matrix. Records used for model fitting should not contain missing phenotypic values.

The provided `train_inbredphe.csv` file is organized as follows:

```text
Line,PH,EW
Y1,148.90273,66.62261111
Y2,153.6443966,59.02416667
Y10,118.0610633,48.06853247
Y11,153.82773,76.03577778
```

The first column (`Line`) contains the sample identifiers, and the remaining columns contain phenotypic values for one or more traits (for example, `PH` and `EW`). In the GUI, users select the target trait for analysis. Sample identifiers in the `Line` column must correspond to the row names or sample IDs in the associated genotype dataset.

### 3. Hybrid phenotype data

Hybrid phenotype data used for `hybrid_predict` must include the two parental ID columns and at least one observed trait column. The example files and GUI use `F` and `M` for the two parents. One or more trait columns (for example `EW` and `PH`) may be present; users specify the target trait required for the analysis in the GUI.

```text
F       M       EW        PH
Y100    Y421    191.7891  2.3927
Y102    Y426    163.7430  2.5459
Y103    Y426    183.7657  2.5431
Y104    Y213    198.4517  2.4940
```

Both parental IDs must occur in the parental inbred genotype dataset. The target trait used for model fitting should not contain missing values. The example file `train_hybridphe.csv` represents this input type.

### 4. Cross information

The `infergen` module requires a two-column file specifying the parents of each target cross. The example files and GUI use `F` and `M` as the two parental columns:

```text
F       M
Y100    Y421
Y102    Y426
Y103    Y426
Y104    Y213
```

Both parental IDs must exactly match IDs in the parental inbred genotype data. The example file `test_crosses_id.csv` represents this input type.

### Input-file consistency checks

Before running an analysis, confirm that:

- sample IDs use exactly the same spelling and capitalization in all related files;
- parental IDs in hybrid phenotype and cross files are present in the parental genotype data;
- phenotype records correspond to the individuals or hybrids represented by the genotype input;
- marker identifiers are compatible between training/reference and target/breeding genotype datasets when `geno_int` is used;
- records used for model fitting do not contain missing phenotypic values.

## GUI modules and usage

### 1. Genotype conversion and quality control (`convert`)

Use `convert` to import genotype data, convert them to the numeric representation used by downstream analyses, apply marker-level QC, and optionally impute missing genotypes.

Typical steps:

1. Open the **convert** tab.
2. Select the genotype format.
3. Upload the genotype file.
4. Set the marker missing-rate and MAF thresholds.
5. Select whether missing genotypes should be imputed.
6. Click **Run Genotype data conversion**.
7. Inspect or download the converted genotype matrix.

### 2. Hybrid genotype inference (`infergen`)

Use `infergen` to infer F1 hybrid genotypes from parental inbred genotypes and the two-column cross file described under **Input data**. Parental genotypes can be uploaded directly or reused from the `convert` module.

### 3. Genotype integration (`geno_int`)

Use `geno_int` to harmonize the training/reference and target/breeding genotype datasets described under **Input data**. The module generates compatible `train_geno` and `breed_geno` matrices that can be reused in `phenotype_predict`.

### 4. Predictability evaluation (`cv`)

Use `cv` to evaluate genomic prediction models by cross-validation. The genotype and phenotype inputs must describe the same individuals or hybrids. Hybrid genotypes produced by `infergen` may be reused directly. User-defined settings include the GS model, number of folds, number of replicates, random seed, and CPU number.

Example settings:

```text
Method:       GBLUP
Folds:        5
Replicates:   2
Seed:         123
CPU:          1
```

### 5. Potential hybrid prediction (`hybrid_predict`)

Use `hybrid_predict` with parental inbred genotype data and the three-column hybrid phenotype training data described under **Input data**. The module predicts potential parental combinations and ranks candidate hybrids according to predicted performance. Users may return all possible crosses or select the top or bottom `n` combinations.

### 6. Phenotype prediction (`phenotype_predict`)

Use `phenotype_predict` with training/reference genotypes, target/breeding genotypes, and individual-level training phenotypes as described under **Input data**. Compatible genotype matrices can be uploaded directly or reused from `geno_int`.

For screenshots and detailed step-by-step instructions for every module, see the [Maize6KGSP User Manual](docs/Maize6KGSP_User_Manual.pdf).

## Genomic selection models

The current version integrates six genomic prediction methods:

| Model | Full name / category | General role |
|:--|:--|:--|
| **GBLUP** | Genomic Best Linear Unbiased Prediction | Linear genomic prediction |
| **BayesB** | Bayesian variable-selection model | Marker-effect prediction |
| **RKHS** | Reproducing Kernel Hilbert Space regression | Nonlinear/kernel prediction |
| **PLS** | Partial Least Squares regression | Dimension-reduction regression |
| **LASSO** | Least Absolute Shrinkage and Selection Operator | Sparse regression |
| **XGBoost** | Extreme Gradient Boosting | Tree-based machine learning |

For a new trait or population, model performance should be evaluated with the `cv` module before final prediction.

## Output

| Module | Major output |
|:--|:--|
| `convert` | QC-filtered and converted genotype matrix |
| `infergen` | Inferred F1 hybrid genotype matrix |
| `geno_int` | Matched `train_geno` and `breed_geno` matrices |
| `cv` | Cross-validation prediction results |
| `hybrid_predict` | Ranked candidate hybrids and predicted phenotypes |
| `phenotype_predict` | Predicted phenotypic values of target individuals |

Interactive GUI tables support browsing, searching, pagination, and result download.

## GUI implementation

The graphical interface is implemented in **R Shiny** and is launched from the installed R package using `Maize6KGSP.GUI()`. The interface integrates the package's genotype-processing and genomic-prediction functions into seven interactive modules. `DT` is used for interactive data-table display, and the remaining analytical dependencies are declared in the package `DESCRIPTION` file.

The GUI runs locally through the R/Shiny environment; no separate desktop executable is required.

## FAQ

### `devtools` is not installed

```r
install.packages("devtools")
```

Then reinstall the package with `devtools::install_github()`.

### Samples are not matched between genotype and phenotype files

Check for inconsistent capitalization, leading/trailing spaces, duplicated IDs, different separators, or parental IDs absent from the genotype file.

### Hybrid genotype inference does not run

Confirm that every parental ID in the crossing file is present in the parental genotype dataset.

### `phenotype_predict` cannot reuse genotype-integration results

Run `geno_int` first in the **same GUI session** and confirm that both `train_geno` and `breed_geno` were generated successfully.

### Which GS model should be selected?

There is no single model that is optimal for every trait and population. Compare candidate models with the `cv` module and select a suitable model based on cross-validation performance.

## Citation

If you use `Maize6KGSP` in your research, please cite the accompanying Maize6K-GS publication.

> **Citation information will be added after publication.**

Before formal publication, the software can be reported as:

```text
Maize6KGSP v0.1
https://github.com/ygn1231/Maize6KGSP
```

## Contact

**Maize6KGSP v0.1**

Developed by **Guangning Yu, Yang Xu, and Chenwu Xu**  
Maintainer: **Guangning Yu**  
Email: **mx120200746@yzu.edu.cn**  
Repository: **https://github.com/ygn1231/Maize6KGSP**

Bug reports, questions, and suggestions are welcome through GitHub Issues or by email.

## License

`Maize6KGSP` is distributed under the **GPL-3** license.
