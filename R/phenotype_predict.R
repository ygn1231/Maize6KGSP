#' @title Predict the Performance of individuals
#' @description The phenotype and genotype data of the training population were used to construct models to predict the phenotype of the breeding population.
#' @param train_fix a matrix of fixed effect for training.
#' @param breed_fix a matrix of fixed effect for breeding.
#' @param train_geno a matrix (n x m) of training population genotypes.
#' @param breed_geno a matrix (n x m) of breddin population genotypes..
#' @param train_phe a vector (n x 1) of phenotype for the training population phenotypes.
#' @param method six GS methods including 'GBLUP', 'BayesB', 'RKHS', 'PLS', 'LASSO', 'XGBoost'. Users may select one of these methods. Default is 'GBLUP'.
#' @return a phenotype of breeding population. 
#' @examples
#' \donttest{
#' ## load example data from Maize6KGSPred package
#' data(hybrid_phe)
#' data(input_geno)
#'
#' ## convert original genotype
#' inbred_gen <- convert(input_geno, type = 'hmp2')
#'
#' ##additive model infer the additive and dominance genotypes of hybrids
#' gena <- infergen(inbred_gen, hybrid_phe)$add
#' set.seed(123)
#' index <- sample(c(TRUE, FALSE), nrow(gena), replace=TRUE, prob=c(0.8,0.2))
#' train <- gena[index, ]
#' breed <- gena[!index, ]
#' t_phe <-hybrid_phe[index, 3]
#
#' p <- phenotype_predict(train_geno = train, breed_geno = breed, train_phe = t_phe)
#'  }
#' @export

phenotype_predict <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe, method = "GBLUP") {
    predict.GBLUP <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        kk <- kin(train_geno)
        kk1 <- tcrossprod(breed_geno, train_geno)/ncol(train_geno)
        y <- train_phe
        n <- nrow(train_geno)
        if (is.null(train_fix)) {
            train_fix <- matrix(1, n, 1)
        } else {
            train_fix <- as.matrix(train_fix)
        }
        parm <- mixed(fix = train_fix, y, list(kk))
        v_i <- parm$v_i
        beta <- parm$beta
        n1 <- nrow(breed_geno)

        if (is.null(breed_fix)) {
            breed_fix <- matrix(1, n1, 1)
        } else {
            breed_fix <- as.matrix(breed_fix)
        }
        G21 <- kk1 * parm$var
        pred_phe <- breed_fix %*% beta + G21 %*% v_i %*% (y - train_fix %*% beta)
        return(pred_phe)
    }

    predict.pls <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        if (!requireNamespace("pls", quietly = TRUE)) {
            stop("pls needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(pls)
        train_geno1 <- cbind(train_fix, train_geno)
        predict_geno1 <- cbind(breed_fix, breed_geno)
        pls.fit <- plsr(train_phe ~ train_geno, ncomp = 5, validation = "CV")
        nn <- as.numeric(which.min(tt <- RMSEP(pls.fit)$val[1, , ][-1]))

        pred_phe <- predict(pls.fit, newdata = breed_geno, ncomp = nn)
        pred_phe <- as.matrix(pred_phe)
        return(pred_phe)
    }

    predict.xgboost <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        if (!requireNamespace("xgboost", quietly = TRUE)) {
            stop("xgboost needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(xgboost)
        train_geno <- cbind(train_fix, train_geno)
        breed_geno <- cbind(breed_fix, breed_geno)
        xg <- xgboost(data = train_geno, label = train_phe, colsample_bytree = 0.9, eta = 0.02, min_child_weight = 11,
            nrounds = 1150, subsample = 0.8, nthread = 8, set.seed(123), verbose = FALSE)
        pred_phe <- as.matrix(predict(xg, breed_geno))
        return(pred_phe)
    }

    predict.lasso <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        if (!requireNamespace("glmnet", quietly = TRUE)) {
            stop("glmnet needed for this function to work. Please install it.", call. = FALSE)
        }
        train_geno <- cbind(train_fix, train_geno)
        breed_geno <- cbind(breed_fix, breed_geno)
        fit0 <- cv.glmnet(x = train_geno, y = train_phe)
        lambda <- fit0$lambda.min
        ffit <- glmnet(x = train_geno, y = train_phe, lambda = lambda)
        pred_phe <- predict(ffit, newx = breed_geno)
        return(pred_phe)
    }

    predict.bayesb <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        if (!requireNamespace("BGLR", quietly = TRUE)) {
            stop("BGLR needed for this function to work. Please install it.", call. = FALSE)
        }
        X <- rbind(train_geno, breed_geno)
        if (is.null(train_fix)) {
            eta <- list(list(X = X, model = "BayesB"))
        } else {
            FIX <- rbind(train_fix, breed_fix)
            eta <- list(list(X = X, model = "BayesB"), list(X = FIX, model = "FIXED"))
        }
        yNA <- rep(NA, nrow(breed_geno))
        yNa <- rbind(as.matrix(train_phe), as.matrix(yNA))
        fm <- BGLR(y = yNa, ETA = eta, verbose = F)
        whichNa <- (nrow(as.matrix(train_phe)) + 1):nrow(yNa)
        pred_phe <- as.matrix(fm$yHat[whichNa])
        return(pred_phe)
    }

    predict.rkhsmk <- function(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe) {
        if (!requireNamespace("BGLR", quietly = TRUE)) {
            stop("BGLR needed for this function to work. Please install it.", call. = FALSE)
        }
        X <- rbind(train_geno, breed_geno)
        M <- scale(X, center = TRUE, scale = TRUE)
        D <- (as.matrix(dist(M, method = "euclidean"))^2)/ncol(X)
        h <- 0.5 * c(1/5, 1, 5)
        if (is.null(train_fix)) {
            FIX <- rbind(train_fix, breed_fix)
            ETA <- list(list(K = exp(-h[1] * D), model = "RKHS"), list(K = exp(-h[2] * D), model = "RKHS"), list(K = exp(-h[3] *
                D), model = "RKHS"))
        } else {

            FIX <- rbind(train_fix, breed_fix)
            ETA <- list(list(K = exp(-h[1] * D), model = "RKHS"), list(K = exp(-h[2] * D), model = "RKHS"), list(K = exp(-h[3] *
                D), model = "RKHS"), list(X = FIX, model = "FIXED"))
        }
        yNA <- rep(NA, nrow(breed_geno))
        yNa <- rbind(as.matrix(train_phe), as.matrix(yNA))
        fm <- BGLR(y = yNa, ETA = ETA, verbose = F)
        whichNa <- (nrow(as.matrix(train_phe)) + 1):nrow(yNa)
        pred_phe <- as.matrix(fm$yHat[whichNa])
        return(pred_phe)
    }

    if ((method == "GBLUP") | (method == "BayesB") | (method == "RKHS") | (method == "PLS") | (method == "LASSO") | (method ==
        "XGBoost") | (method == "ALL")) {

        if (method == "GBLUP") {
		    print("Predict by GBLUP ...")
            res <- predict.GBLUP(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
			print("Predict by GBLUP ...ended")
        }
        if (method == "BayesB") {
		    print("Predict by BayesB...")
            res <- predict.bayesb(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
			print("Predict by BayesB ...ended")
        }
        if (method == "RKHS") {
		    print("Predict by RKHS ...")
            res <- predict.rkhsmk(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
			print("Predict by RKHS ...ended")
        }
        if (method == "PLS") {
		    print("Predict by PLS...")
            res <- predict.pls(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
			print("Predict by PLS...ended.")
        }
        if (method == "LASSO") {
		    print("Predict by LASSO ...")
            res <- predict.lasso(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
			print("Predict by LASSO ...ended")
        }

        if (method == "XGBoost") {
		    print("Predict by XGBoost...")
            res <- predict.xgboost(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
		    print("Predict by XGBoost...ended")	
        }

        if (method == "ALL") {
            print("Predict by ALL...")
            GBLUP <- predict.GBLUP(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            BayesB <- predict.bayesb(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            RKHS <- predict.rkhsmk(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            PLS <- predict.pls(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            LASSO <- predict.lasso(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            XGBoost <- predict.xgboost(train_fix = NULL, breed_fix = NULL, train_geno, breed_geno, train_phe)
            res <- cbind(GBLUP, BayesB, RKHS, PLS, LASSO, XGBoost)
            colnames(res) <- c("GBLUP", "BayesB", "RKHS", "PLS", " LASSO", "XGBoost")
            print("Predict by ALL...ended.")
        }
    } else {
        stop("Please choose a predict method: GBLUP, BayesB, RKHS, PLS, LASSO, XGBoost.")
    }
    rownames(res) <- rownames(breed_geno)
    return(res)
}
