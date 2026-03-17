#' @title Genotype data integration
#' @description Match the genotypic data of the training population and breeding population, ensuring consistency of markers.
#' @param train_input_geno the genotypic data of the training population in HapMap format,VCF format or in numeric format. The names of individuals should be provided. Missing (NA) values are allowed.
#' @param breed_input_geno the genotypic data of the breeding population in HapMap format,VCF format or in numeric format. The names of individuals should be provided. Missing (NA) values are allowed.
#' @param type the type of genotype. There are three options: 'hmp1' for genotypes in HapMap format with single bit, 'hmp2' for genotypes in HapMap format with double bit, 'vcf' for genotypes in VCF and 'num' for genotypes in numeric format.
#' @param missingrate max missing percentage for each SNP, default is 0.2.
#' @param maf minor allele frequency for each SNP, default is 0.05.
#' @param impute logical. If TRUE, imputation. Default is TRUE.
#' @param dir This file is for the input path.When type= 'vcf', it must be provided, default is NULL.
#' @param train_crosses a data frame with two columns. The first column and the second column are the names of male and female parents of the corresponding  training population crosses. Default is NULL.
#' @param breed_crosses a data frame with two columns. The first column and the second column are the names of male and female parents of the corresponding  breed population crosses. Default is NULL.
#' @return A matrix of genotypes in numeric format, coded as 1, 0, -1 for AA, Aa, aa. Each row represents an individual and each column represents a marker. The rownames of the matrix are the names of individuals.
#' @export

geno_int <- function(train_input_geno, breed_input_geno, type, missingrate, maf, impute=TRUE,dir=NULL,train_crosses=NULL,breed_crosses=NULL) {
  
  if(is.null(train_crosses)&is.null(breed_crosses)){
    train_gen <- convert(input_geno = train_input_geno, type, missingrate, maf, impute,dir)
    breed_gen <- convert(input_geno = breed_input_geno, type, missingrate, maf, impute,dir)}
    else{
      train_gen <- convert(input_geno = train_input_geno, type, missingrate, maf, impute,dir)
       breed_gen <- convert(input_geno = breed_input_geno, type, missingrate, maf, impute,dir)
       train_gen<-infergen(inbred_gen = train_gen,hybrid_phe =train_crosses)$add
       breed_gen<-infergen(inbred_gen = breed_gen,hybrid_phe =breed_crosses)$add
       }
    col1 <- colnames(train_gen)
    col2 <- colnames(breed_gen)
    common_cols <- intersect(col1, col2)
    mat1_common <- train_gen[, common_cols, drop = FALSE]
    mat2_common <- breed_gen[, common_cols, drop = FALSE]
    return(list(train_geno = mat1_common, breed_geno = mat2_common))
}
