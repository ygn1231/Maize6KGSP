#' @title Convert Genotype
#' @description Convert genotypes in HapMap format ,VCF format or in numeric format for convert function.
#' @param input_geno  genotype in HapMap format,VCF format or in numeric format. The names of individuals should be provided. Missing (NA) values are allowed.
#' @param type the type of genotype. There are three options: "hmp1" for genotypes in HapMap format with single bit, "hmp2" for genotypes in HapMap format with double bit, "vcf" for genotypes in VCF and "num" for genotypes in numeric format.
#' @param missingrate max missing percentage for each SNP, default is 0.2.
#' @param maf minor allele frequency for each SNP, default is 0.05.
#' @param impute logical. If TRUE, imputation. Default is TRUE.
#' @param dir This file is for the input path.When type= "vcf", it must be provided, default is NULL.
#' @return A matrix of genotypes in numeric format, coded as 1, 0, -1 for AA, Aa, aa. Each row represents an individual and each column represents a marker. The rownames of the matrix are the names of individuals.
#' @export
#'
#' @examples
#' ## load genotype in HapMap format with double bit
#' data(input_geno)
#'
#' ## convert genotype for Maize6KGSPred package
#' inbred_gen <- convert(input_geno, type = "hmp2")
#'
#'
#' ## load genotype in numeric format
#' data(input_geno1)
#' head(input_geno1)
#'
#' ## convert genotype for Maize6KGSPred package
#' inbred_gen1 <- convert(input_geno1, type = "num")
#'

convert<-function(input_geno, type = c("hmp1", "hmp2", "num","vcf"), missingrate = 0.2, maf = 0.05, impute = TRUE,dir=NULL) {
    
    if (type != "vcf") {  
      if (is.character(input_geno)) {  
        inputgeno <- as.data.frame(fread(input_geno, header = T, stringsAsFactors = F))  
      } else {  
        inputgeno<-input_geno
      }  
    } else if (type == "vcf") {  
      if (is.character(input_geno)) {  
        vfile<-input_geno 
      } else {  
        stop("Please input a VCF file path as a character string.")  
      }  
    } 
      
    if (type == "num") {
      genotype <- as.matrix(inputgeno)
      rownames(genotype)<-inputgeno[,1]
      gen_missingrate <- apply(genotype, 1, function(x) {
        rate <- length(which(is.na(x)))/ncol(genotype)
        return(rate)
      })
      num_filter <- which(gen_missingrate <= missingrate)
      gen_filter <- genotype[num_filter, ]
      row.names(gen_filter)<-genotype[,1]
      gen <- apply(gen_filter, 2, function(x) {
        x1 <- as.numeric(x)
        return(x1)
      })}
    if (type == "vcf"){
      VCF.Numeralization <- function(x){
        x[x=="0/0"] = 1
        x[x=="0/1"] = 0
        x[x=="1/0"] = 0
        x[x=="1/1"] = -1
        x[x=="./1"] = "NA"
        x[x=="1/."] = "NA"
        x[x=="./0"] = "NA"
        x[x=="0/."] = "NA"
        x[x=="./."] = "NA"
        return(x)
      }
      dofile <- TRUE
      i <- 0
      sep<-"\t"
      fileVCFCon <- file(description=vfile[1], open="r")
      while(dofile){
        i <- i + 1
        tt <- readLines(fileVCFCon, n=1)
        char <- substr(tt, 1, 2)
        if(char != "##"){
          dofile <- FALSE
          vcf.jump <- i - 1
        }
      }
      cat(" Skip row number:", vcf.jump, "\n")
      close.connection(fileVCFCon)
      
      fileVCFCon <- file(description=vfile[1], open="r")     
      jj <- readLines(fileVCFCon, n=vcf.jump)
      tt <- readLines(fileVCFCon, n=1, skipNul=1)
      close.connection(fileVCFCon)
      
      tt3 <- unlist(strsplit(tt, "\t"))
      tt2 <- unlist(strsplit(tt3, "-9_"))
      ID <- as.vector(tt2[-c(1:9)])
      ID <- ID[ID!=""]
      ID1 <- ID
      ns <- length(ID1) 
      cat(" Number of individuals:", ns, "\n")
      nFile <- length(vfile)
      cat(" Numericilization...\n")
      for (theFile in 1:nFile){
        fileVCFCon <- file(description=vfile[theFile], open="r")
        if(theFile == 1){
          output_numeric_file <- file.path(dir, "numeric_output.txt")  
          output_map_file <- file.path(dir, "map_output.txt")
          fileNumCon <- file(description=output_numeric_file, open="w")
          fileMapCon <- file(description=output_map_file, open="w")
        }
        inFile <- TRUE
        i <- 0
        jj <- readLines(fileVCFCon, n=vcf.jump+1)
        while(inFile){
          i <- i + 1
          if(i %% 1000 == 0) cat(paste(" Number of Markers Written into File: ", theFile, ": ", i, sep=""), "\n")
          tt <- readLines(fileVCFCon, n=1)
          tt2 <- unlist(strsplit(x=tt, split="\t", fixed=TRUE))
          if(is.null(tt2[1])){
            cat(paste(" Number of Markers Written into File: ", theFile, ": ", i-1, sep=""), "\n")
            inFile=FALSE
          }
          if(inFile){
            rs <- tt2[3]
            chr <- tt2[1]
            pos <- tt2[2]
            writeLines(as.character(rs), fileMapCon, sep=sep)
            writeLines(as.character(chr), fileMapCon, sep=sep)
            writeLines(as.character(pos), fileMapCon, sep="\n")
            GD <- VCF.Numeralization(x=tt2[-c(1:9)])
            writeLines(as.character(GD[1:(ns-1)]), fileNumCon, sep=sep)
            writeLines(as.character(GD[ns]), fileNumCon, sep="\n")
          }
        } 
        close.connection(fileVCFCon)
      } 
      close.connection(fileNumCon)
      close.connection(fileMapCon)
      cat(" Preparation for NUMERIC data is done!\n")
      
      gen_numeric<-fread(output_numeric_file,header = F,stringsAsFactors=T)
      gen_map<-fread(output_map_file,header = F,stringsAsFactors=T)
      colnames(gen_numeric)<-ID1
      gen_numeric<-as.matrix(gen_numeric)
      rownames(gen_numeric)<-gen_map$V1
    gen_missingrate <- apply(gen_numeric, 1, function(x) {
      rate <- length(which(is.na(x)))/ncol(gen_numeric)
      return(rate)
    })
    num_filter <- which(gen_missingrate <= missingrate)
    gen_filter <- gen_numeric[num_filter, ]
    gen<-gen_filter
  }
    if (type == "hmp1"||type == "hmp2") {
      inputgeno[inputgeno == "N"] = NA
      inputgeno[inputgeno == "NN"] = NA
      genotype <- inputgeno[, -c(1:11)]
      rownames(genotype)<-inputgeno[,1]
      gen_missingrate <- apply(genotype, 1, function(x) {
        rate <- length(which(is.na(x)))/ncol(genotype)
        return(rate)
      })
      num_filter <- which(gen_missingrate <= missingrate)
      gen_filter <- genotype[num_filter, ]
      map <- inputgeno[num_filter, c(1:4)]
      x1 <- substr(map[, 2], 1, 1)
      x2 <- substr(map[, 2], 3, 3)
      aa <- paste(x1, x1, sep = "")
      bb <- paste(x2, x2, sep = "")
      cc <- paste(x1, x2, sep = "")
	  dd <- paste(x2, x1, sep = "")
      if (type == "hmp1") {
        gen <- apply(gen_filter, 2, function(x) {
          x[x == x1] <- 1
          x[x == x2] <- -1
          x[x %in% c("R", "Y", "S", "W", "K", "M")] <- 0
          x1 <- as.numeric(x)
          return(x1)
        })
      }
      if (type == "hmp2") {
        gen <- apply(gen_filter, 2, function(x) {
          x[x == aa] <- 1
          x[x == bb] <- -1
          x[x == cc] <- 0
		  x[x == dd] <- 0
		  
          x1 <- as.numeric(x)
          return(x1)
        })
      }
     
    }
  rownames(gen)<-rownames(gen_filter)
    if (impute ) {
    gene1 <- apply(gen, 1, function(x) {
      x[which(is.na(x))] <- mean(x, na.rm = TRUE)
      return(x)
    })
  } else {
    gene1 <- t(gen)
  }
  gen_maf <- apply(gene1, 2, function(x) {
    maf_rate <- (length(which(x == -1)) + (1/2 * (length(which(x == 0)))))/ (length(which(x == -1))+length(which(x == 0))+length(which(x == 1)))
    return(maf_rate)
  })
  num_gene1 <- which(gen_maf >= maf)
  gene2 <- gene1[, num_gene1]
  return(gene2)
}

 
