#' @title Predict the Performance of Hybrids
#' @description Predict all potential crosses of a given set of parents using a subset of crosses as the training sample.
#' @param inbred_gen a matrix for genotypes of parental lines in numeric format, coded as 1, 0 and -1. The row.names of inbred_gen must be provied. It can be obtained from the original genotype using  \code{\link{convert}} function.
#' @param hybrid_phe a data frame with three columns. The first column and the second column are the names of male and female parents of the corresponding hybrids, respectively; the third column is the phenotypic values of hybrids.
#' The names of male and female parents must match the rownames of inbred_gen. Missing (NA) values are not allowed.
#' @param method six GS methods including 'GBLUP', 'BayesB', 'RKHS', 'PLS', 'LASSO', 'XGBoost'.
#' Users may select one of these methods. Default is 'GBLUP'.
#' @param select the selection of hybrids based on the prediction results. There are three options: select = 'all', which selects all potential crosses. select = 'top', which selects the top n crosses. select = 'bottom', which selects the bottom n crosses. The n is determined by the param number.
#' @param number the number of selected top or bottom hybrids, only when select = 'top' or select = 'bottom'.
#' @return a data frame of prediction results with two columns. The first column denotes the names of male and female parents of the predicted hybrids, and the second column denotes the phenotypic values of the predicted hybrids.
#' @examples
#' \donttest{
#' ## load example data from Maize6KGSPred package
#' data(hybrid_phe)
#' data(input_geno)
#' inbred_gen <- convert(input_geno, type = 'hmp2')
#'
#' pred<-hybrid.predict(inbred_gen,hybrid_phe,method='LASSO',select='top',number='100')
#'  }
#' @export
hybrid.predict <- function(inbred_gen, hybrid_phe, method = "GBLUP", select = "top", number = "100") {
    predict.xgboost <- function(inbred_gen, hybrid_phe) {
        if (!requireNamespace("xgboost", quietly = TRUE)) {
            stop("xgboost needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(xgboost)
        x <- gena
        xg <- xgboost(x = x, y = y, colsample_bytree = 0.9, eta = 0.02, min_child_weight = 11,
            nrounds = 1150, subsample = 0.8, nthreads = 8, set.seed(123), verbose = FALSE)
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            X <- ha1
            yhat <- predict(xg, X)
            ynew <- c(ynew, yhat)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        ynew <- as.matrix(ynew)
        row.names(ynew) <- phe_name
        return(ynew)
    }
    predict.bayesb <- function(inbred_gen, hybrid_phe) {
        if (!requireNamespace("BGLR", quietly = TRUE)) {
            stop("BGLR needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(BGLR)
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            X <- rbind(gena, ha1)
            yNa <- as.matrix(rep(NA, nrow(ha1)))
            yNA <- c(y, yNa)
            yNA <- as.matrix(yNA)
            eta <- list(list(X = X, model = "BayesB"))
            fm <- BGLR(y = yNA, ETA = eta, verbose = F)
            yhat <- fm$yHat
            y <- as.matrix(y)
            yhat1 <- yhat[-c(1:nrow(y))]
            ynew <- c(ynew, yhat1)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        ynew <- as.matrix(ynew)
        row.names(ynew) <- phe_name
        return(ynew)
    }
    predict.lasso <- function(inbred_gen, hybrid_phe) {
        if (!requireNamespace("glmnet", quietly = TRUE)) {
            stop("glmnet needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(glmnet)
        x <- gena
        fit0 <- cv.glmnet(x, y)
        lambda <- fit0$lambda.min
        ffit <- glmnet(x, y, lambda = lambda)
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            X <- ha1
            yhat <- predict(ffit, newx = X)
            ynew <- c(ynew, yhat)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        ynew <- as.matrix(ynew)
        row.names(ynew) <- phe_name
        return(ynew)
    }
    predict.pls <- function(inbred_gen, hybrid_phe) {
        if (!requireNamespace("pls", quietly = TRUE)) {
            stop("pls needed for this function to work. Please install it.", call. = FALSE)
        }
        # library(pls)
        x <- gena
        pls.fit <- plsr(y ~ x, ncomp = 5, validation = "CV")
        nn <- as.numeric(which.min(tt <- RMSEP(pls.fit)$val[1, , ][-1]))
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            X <- ha1
            yhat <- predict(pls.fit, newdata = X, ncomp = nn)
            ynew <- c(ynew, yhat)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        ynew <- as.matrix(ynew)
        row.names(ynew) <- phe_name
        return(ynew)
    }
    predict.GBLUP <- function(inbred_gen, hybrid_phe) {
        n <- nrow(hybrid_phe)
        ka <- kin(gena)
        fix <- matrix(1, n, 1)
        parm <- mixed(fix = fix, y = y, kk = list(ka))
        v_i <- parm$v_i
        beta <- parm$beta
        va <- parm$var[1]
        ve <- parm$ve
        ka21 <- NULL
        phe_name <- NULL
        predparent_gen <- t(inbred_gen)
        pred_name <- colnames(predparent_gen)
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            ka2 <- tcrossprod(ha1, gena)/ncol(gena)
            ka21 <- rbind(ka21, ka2)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        n1 <- nrow(ka21)
        fixnew <- matrix(1, n1, 1)
        G21 <- ka21 * va
        pred_phe <- fixnew %*% beta + G21 %*% v_i %*% (y - fix %*% beta)
        row.names(pred_phe) <- phe_name
        return(pred_phe)
    }
    predict.rkhsmk <- function(inbred_gen, hybrid_phe) {
        # library(BGLR)
        for (i in 1:(ncol(predparent_gen) - 1)) {
            ha1 <- t((predparent_gen[, i] + predparent_gen[, -(1:i)])/2)
            X1 <- rbind(gena, ha1)
            X <- X1
            yNa <- as.matrix(rep(NA, nrow(ha1)))
            yNA <- c(y, yNa)
            yNA <- as.matrix(yNA)
            M <- scale(X, center = TRUE, scale = TRUE)
            D <- (as.matrix(dist(M, method = "euclidean"))^2)/ncol(X)
            h <- 0.5 * c(1/5, 1, 5)
            ETA <- list(list(K = exp(-h[1] * D), model = "RKHS"), list(K = exp(-h[2] * D), model = "RKHS"), list(K = exp(-h[3] *
                D), model = "RKHS"))
            fm <- BGLR(y = yNA, ETA = ETA, verbose = F)
            yhat <- fm$yHat
            y <- as.matrix(y)
            yhat1 <- yhat[-c(1:nrow(y))]
            ynew <- c(ynew, yhat1)
            test_name <- paste(pred_name[i], pred_name[-(1:i)], sep = "/")
            phe_name <- c(phe_name, test_name)
        }
        ynew <- as.matrix(ynew)
        row.names(ynew) <- phe_name
        return(ynew)
    }
    gena <- infergen(inbred_gen, hybrid_phe)$add
    y <- hybrid_phe[, 3]
    predparent_gen <- t(inbred_gen)
    pred_name <- colnames(predparent_gen)
    predparent_gen <- as.matrix(predparent_gen)
    phe_name <- NULL
    ynew <- NULL
    if ((method == "XGBoost") | (method == "BayesB") | (method == "LASSO") | (method == "GBLUP") | (method == "RKHS") |
        (method == "PLS")) {
        if (method == "XGBoost") {
            print("Predict by XGBoost...")
            predict_xgboost <- predict.xgboost(inbred_gen, hybrid_phe)
            Results <- predict_xgboost
            print("Predict by XGBoost...ended")
        }
        if (method == "BayesB") {
            print("Predict by BayesB...")
            print("additive model")
            predict_bayesb <- predict.bayesb(inbred_gen, hybrid_phe)
            Results <- predict_bayesb

            print("Predict by BayesB ...ended")
        }
        if (method == "LASSO") {
            print("Predict by LASSO ...")
            print("additive model")
            predict_lasso <- predict.lasso(inbred_gen, hybrid_phe)
            Results <- predict_lasso
            print("Predict by LASSO ...ended")
        }


        if (method == "PLS") {
            print("Predict by PLS...")
            print("additive model")
            predict_pls <- predict.pls(inbred_gen, hybrid_phe)
            Results <- predict_pls
            print("Predict by PLS...ended.")
        }
        if (method == "GBLUP") {
            print("Predict by GBLUP ...")
            print("additive model")
            predict_GBLUP <- predict.GBLUP(inbred_gen, hybrid_phe)
            Results <- predict_GBLUP
            print("Predict by GBLUP ...ended")
        }
        if (method == "RKHS") {
            print("Predict by RKHS ...")
            print("additive model")
            predict_rkhsmk <- predict.rkhsmk(inbred_gen, hybrid_phe)
            Results <- predict_rkhsmk
            print("Predict by RKHS ...ended")
        }
        if (select == "all") {
            Results_select <- as.data.frame(Results)
            colnames(Results_select) <- paste("all_", nrow(Results), sep = "")
        } else if (select == "top") {
            Results_select <- as.data.frame(sort(Results[, 1], decreasing = T)[c(1:number)])
            names(Results_select) <- paste("top_", number, sep = "")
        } else if (select == "bottom") {
            Results_select <- as.data.frame(sort(Results[, 1], decreasing = F)[c(1:number)])
            colnames(Results_select) <- paste("bottom_", number, sep = "")
        }
        return(Results_select)
    } else {
        stop("Please choose a predict method: GBLUP, BayesB, RKHS, PLS, LASSO, EN, XGBoost.")
    }  # End of all predict methods
    return(Results)
}
