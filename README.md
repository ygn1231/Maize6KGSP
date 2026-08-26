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

`Maize6KGSP` is an R package with a graphical user interface (GUI) developed for the **Maize6K-GS array**.  
It provides an integrated and user-friendly workflow for genotype processing, F1 hybrid genotype inference, genomic prediction model evaluation, hybrid performance prediction, and phenotype prediction in maize breeding populations.

The package is designed to connect **genotyping → model evaluation → genomic prediction → breeding selection** in one platform, while allowing users with limited programming experience to perform routine genomic selection analyses through a Shiny-based interface.

---

## Contents

- [OVERVIEW](#overview)
- [CITATION](#citation)
- [GETTING STARTED](#getting-started)
  - [Installation](#installation)
  - [Launch Maize6KGSP](#launch-maize6kgsp)
  - [Example datasets](#example-datasets)
- [WORKFLOW](#workflow)
- [INPUT](#input)
  - [Genotype data](#genotype-data)
  - [Hybrid phenotype data](#hybrid-phenotype-data)
  - [Cross information](#cross-information)
- [USAGE](#usage)
  - [1. Genotype conversion and quality control](#1-genotype-conversion-and-quality-control)
  - [2. Hybrid genotype inference](#2-hybrid-genotype-inference)
  - [3. Genotype integration](#3-genotype-integration)
  - [4. Predictability evaluation](#4-predictability-evaluation)
  - [5. Potential hybrid prediction](#5-potential-hybrid-prediction)
  - [6. Phenotype prediction](#6-phenotype-prediction)
- [GENOMIC SELECTION MODELS](#genomic-selection-models)
- [OUTPUT](#output)
- [FAQ AND HINTS](#faq-and-hints)
- [CONTACT](#contact)

---

## OVERVIEW

`Maize6KGSP` was developed as a genomic prediction platform for data generated using the **Maize6K-GS array**. It integrates genotype and phenotype data into a unified workflow for genomic selection and breeding decision support.

The current GUI contains seven modules:

| Module | Main function |
|:--|:--|
| **home** | Platform overview and one-click navigation |
| **convert** | Genotype format conversion, marker QC, and optional missing-genotype imputation |
| **infergen** | F1 hybrid genotype inference from parental genotypes |
| **geno_int** | Genotype harmonization between training and breeding populations |
| **cv** | Cross-validation-based evaluation of genomic prediction models |
| **hybrid_predict** | Prediction and ranking of potential hybrid combinations |
| **phenotype_predict** | Phenotype prediction for target inbred or hybrid populations |

### Main features

- 🌽 Designed for the **Maize6K-GS array**
- 🧬 Supports multiple commonly used genotype formats
- 🧹 Provides genotype conversion, quality control, and optional imputation
- 🌱 Infers F1 hybrid genotypes from parental lines
- 🔗 Harmonizes genotype datasets from training and prediction populations
- 📊 Evaluates genomic prediction models by cross-validation
- 🤖 Integrates six genomic selection algorithms
- 🔮 Predicts phenotypes of untested hybrids or breeding materials
- 🏆 Ranks candidate crosses according to predicted performance
- 🖥️ Provides a graphical interface requiring no routine coding

`Maize6KGSP` was developed by **Guangning Yu, Yang Xu, and Chenwu Xu**.

---

## CITATION

If you use `Maize6KGSP` in your research, please cite the accompanying Maize6K-GS publication.

> **Citation information will be added after publication.**

If you use the GitHub version before the associated article is formally published, please report the package name and version in the Methods section:

```text
Maize6KGSP v0.1
https://github.com/ygn1231/Maize6KGSP
```

---

## GETTING STARTED

`Maize6KGSP` is written in R and requires **R >= 4.1.0**.  
RStudio is recommended for convenient installation and use of the graphical interface.

### Installation

The package can be installed directly from GitHub using `devtools`:

```r
# Install devtools if necessary
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
}

devtools::install_github("ygn1231/Maize6KGSP", force = TRUE)
```

Alternatively, the repository can be cloned and installed locally:

```bash
git clone https://github.com/ygn1231/Maize6KGSP.git
```

Then, in R:

```r
install.packages("Maize6KGSP", repos = NULL, type = "source")
```

### Launch Maize6KGSP

After successful installation:

```r
library(Maize6KGSP)

Maize6KGSP.GUI()
```

The GUI will open in the default browser or RStudio Viewer.

### Example datasets

Several example files are available directly in the repository:

```text
train_inbred.hmp.txt
test_inbred.hmp.txt
train_inbredphe.csv
train_hybridphe.csv
test_crosses_id.csv
```

These files can be used to become familiar with genotype conversion, hybrid genotype inference, model evaluation, genotype integration, and genomic prediction.

A recommended first test is:

```text
train_inbred.hmp.txt
        ↓
      convert
        ↓
     infergen
        ↓
        cv
        ↓
 hybrid_predict
```

---

## WORKFLOW

The modules can be used independently, but they are designed to form an integrated genomic breeding workflow.

```text
                         ┌─────────────────────┐
                         │  Raw genotype data  │
                         └──────────┬──────────┘
                                    │
                                    ▼
                              ┌───────────┐
                              │  convert  │
                              └─────┬─────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
                  ▼                                   ▼
           ┌─────────────┐                      ┌────────────┐
           │  infergen   │                      │  geno_int  │
           └──────┬──────┘                      └─────┬──────┘
                  │                                   │
                  ▼                                   ▼
             ┌────────┐                       ┌───────────────────┐
             │   cv   │                       │ phenotype_predict │
             └───┬────┘                       └───────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │ hybrid_predict │
        └────────────────┘
```

### Typical breeding applications

| Breeding objective | Recommended module(s) |
|:--|:--|
| Convert raw genotype files | `convert` |
| Apply genotype QC and imputation | `convert` |
| Infer genotypes of known F1 crosses | `infergen` |
| Compare GS models | `cv` |
| Match training and breeding genotypes | `geno_int` |
| Rank untested hybrid combinations | `hybrid_predict` |
| Predict target inbred/hybrid phenotypes | `phenotype_predict` |

---

## INPUT

### Genotype data

The `convert` and `geno_int` modules support four genotype input types:

1. **HapMap single-bit**
2. **HapMap double-bit**
3. **VCF**
4. **Numeric genotype matrix**

Marker-level quality control can be performed using:

- marker missing rate
- minor allele frequency (MAF)
- optional missing-genotype imputation

#### Example: numeric genotype matrix

```text
ID      Marker1   Marker2   Marker3   Marker4
Y10          1        -1         1         0
Y25         -1         1         1         1
Y104         1         0        -1         1
Y105         1         1         0        -1
```

> **Important:** sample names and marker identifiers should remain consistent across genotype, phenotype, and cross files.

---

### Hybrid phenotype data

Hybrid phenotype data used for training should contain three columns:

```text
Female    Male    Trait
Y104      Y213    2.4940
Y105      Y192    2.4668
Y105      Y207    2.2430
Y105      Y219    2.3917
```

The first two columns identify the parents of each hybrid, and the third column contains the observed phenotypic value.

Requirements:

- parental IDs must exist in the parental genotype dataset;
- records used for training should have non-missing phenotypic values;
- the phenotype column should contain the trait used for model fitting.

---

### Cross information

The `infergen` module requires a two-column file describing the target crosses:

```text
Parent1    Parent2
Y104       Y213
Y105       Y192
Y105       Y207
Y107       Y25
```

Both parental IDs must match individuals in the uploaded parental genotype matrix.

---

## USAGE

### 1. Genotype conversion and quality control

The **convert** module imports raw genotype files and converts them into the numeric representation required by downstream analyses.

#### Steps

1. Open the **convert** tab.
2. Select the genotype format.
3. Upload the genotype file.
4. Set the marker missing-rate threshold.
5. Set the MAF threshold.
6. Choose whether missing genotypes should be imputed.
7. Click **Run Genotype data conversion**.
8. Inspect the result in the interactive table.
9. Download the converted genotype data if needed.

#### Main output

```text
Converted numerical genotype matrix
```

The result can also be reused directly by other modules in the same GUI session.

---

### 2. Hybrid genotype inference

The **infergen** module infers F1 hybrid genotypes from parental inbred genotypes and a user-defined cross list.

#### Input

- parental inbred genotype matrix
- target cross file

The parental genotype source can be either:

```text
Upload file
```

or

```text
Use convert result
```

#### Run

Click:

```text
Run Hybrid genotype inference
```

#### Main output

```text
F1 hybrid genotype matrix
```

The inferred genotypes can be downloaded or passed directly to the `cv` module.

---

### 3. Genotype integration

The **geno_int** module harmonizes genotype datasets from training and breeding populations.

This step is especially useful when the two populations were genotyped, formatted, or prepared separately.

#### Input

```text
Training population genotype
Breeding population genotype
```

After matching compatible genotype information, the module generates:

```text
train_geno
breed_geno
```

These two matrices contain compatible marker information and can be reused directly by `phenotype_predict`.

> **Important:** phenotype records used for model training must correspond to individuals in `train_geno`, while target individuals must correspond to `breed_geno`.

---

### 4. Predictability evaluation

The **cv** module evaluates the predictive ability of genomic selection models through cross-validation.

#### Input

- genotype data
- phenotype data
- GS model
- number of folds
- number of replicates
- random seed
- number of CPUs

#### Example

```text
Method:       GBLUP
Folds:        5
Replicates:   2
Seed:         123
CPU:          1
```

Click:

```text
Run Predictability evaluation
```

The results can be inspected in the interactive table and exported using:

```text
Download CV Results
```

The `cv` module is recommended before large-scale prediction so that an appropriate model can be selected for the trait and population under study.

---

### 5. Potential hybrid prediction

The **hybrid_predict** module predicts the performance of potential crosses among a set of parental inbred lines.

For `n` parental lines, all pairwise combinations correspond to:

\[
n(n-1)/2
\]

possible crosses.

#### Input

- parental genotype data
- observed hybrid phenotypes for model training
- selected GS model

#### Candidate selection modes

The GUI provides three options:

```text
All potential crosses
Top n crosses
Bottom n crosses
```

When `Top n` or `Bottom n` is selected, specify the number of candidate hybrids to retain.

#### Main output

```text
Cross ID    Predicted phenotype
```

The resulting hybrids can be ranked and downloaded for downstream breeding decisions.

---

### 6. Phenotype prediction

The **phenotype_predict** module predicts phenotypic values for a target breeding population using a model trained in a reference population.

It can be applied to:

- inbred breeding populations
- hybrid breeding populations

#### Required input

```text
Training genotype
Breeding genotype
Training phenotype
GS model
```

The genotype matrices may be uploaded independently or reused from `geno_int`.

Click:

```text
Run Phenotype Prediction
```

#### Main output

```text
Individual    Predicted phenotype
```

The complete prediction table can be downloaded for selection, ranking, or subsequent breeding analyses.

---

## GENOMIC SELECTION MODELS

The current version integrates six genomic prediction methods:

| Model | Full name / category | General role |
|:--|:--|:--|
| **GBLUP** | Genomic Best Linear Unbiased Prediction | Linear genomic prediction |
| **BayesB** | Bayesian variable-selection model | Marker-effect prediction |
| **RKHS** | Reproducing Kernel Hilbert Space regression | Nonlinear/kernel prediction |
| **PLS** | Partial Least Squares regression | Dimension-reduction regression |
| **LASSO** | Least Absolute Shrinkage and Selection Operator | Sparse regression |
| **XGBoost** | Extreme Gradient Boosting | Tree-based machine learning |

For a new trait or population, we recommend comparing candidate models with the `cv` module before performing final predictions.

---

## OUTPUT

Depending on the module used, `Maize6KGSP` can generate:

| Module | Major output |
|:--|:--|
| `convert` | QC-filtered and converted genotype matrix |
| `infergen` | Inferred F1 hybrid genotype matrix |
| `geno_int` | Matched `train_geno` and `breed_geno` matrices |
| `cv` | Cross-validation prediction results |
| `hybrid_predict` | Ranked candidate hybrids and predicted phenotypes |
| `phenotype_predict` | Predicted phenotypic values of target individuals |

Interactive result tables in the GUI support:

- browsing
- searching
- pagination
- result download

For reproducible genomic prediction analyses, it is recommended to retain:

```text
Genotype data
Phenotype data
Cross information
Model settings
Random seed
Downloaded prediction results
```

---

## FAQ AND HINTS

### 1. `devtools` is not installed

Install it first:

```r
install.packages("devtools")
```

Then run:

```r
devtools::install_github("ygn1231/Maize6KGSP", force = TRUE)
```

---

### 2. Samples are not matched between genotype and phenotype files

Check whether sample names are exactly identical.

Common causes include:

- inconsistent capitalization;
- leading/trailing spaces;
- duplicated IDs;
- different separators;
- parental IDs absent from the genotype file.

---

### 3. Hybrid genotype inference does not run

Check that:

```text
Parent1 ∈ parental genotype IDs
Parent2 ∈ parental genotype IDs
```

for every cross in the input file.

---

### 4. `phenotype_predict` cannot reuse genotype integration results

Run `geno_int` first in the **same GUI session** and confirm that both:

```text
train_geno
breed_geno
```

were successfully generated.

---

### 5. Which GS model should be selected?

There is no single model that is optimal for every trait and population.

A recommended workflow is:

```text
cv
 ↓
compare prediction performance
 ↓
select model
 ↓
hybrid_predict / phenotype_predict
```

---

### 6. Why do predicted hybrid rankings differ among models?

Different GS algorithms make different assumptions about marker effects and genetic architecture. Therefore, model ranking may change across traits and populations. Cross-validation should be used to evaluate model suitability before final prediction.

---

## CONTACT

**Maize6KGSP v0.1**

Developed by:

**Guangning Yu · Yang Xu · Chenwu Xu**

Maintainer:

**Guangning Yu**

Email:

**mx120200746@yzu.edu.cn**

Repository:

**https://github.com/ygn1231/Maize6KGSP**

Bug reports, questions, and suggestions are welcome through the GitHub Issues page or by email.

---

## LICENSE

`Maize6KGSP` is distributed under the **GPL-3** license.
