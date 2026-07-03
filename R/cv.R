#' @title Evaluate Trait Predictability via Cross Validation
#' @description The cv function evaluates trait predictability based on six GS methods via k-fold cross validation. The trait predictability is defined as the squared Pearson correlation coefficient between the observed and the predicted trait values.
#' @param fix a design matrix of the fixed effects.
#' @param gen a matrix (n x m) of genotypes.
#' @param y a vector(n x 1) of the phenotypic values.
#' @param method six GS methods including 'GBLUP', 'BayesB', 'RKHS', 'PLS', 'LASSO', 'XGBoost'.
#' Users may select one of these methods or all of them simultaneously with 'ALL'. Default is 'GBLUP'.
#' @param drawplot when method ='ALL', user may select TRUE for a barplot about six GS methods. Default is TRUE.
#' @param nfold the number of folds. Default is 5.
#' @param nTimes the number of independent replicates for the cross-validation. Default is 1.
#' @param seed the random number. Default is 1234.
#' @param CPU the number of CPU.
#' @return Trait predictability
#' @examples
#' \donttest{
#' ## load example data
#' data(hybrid_phe)
#' data(input_geno)
#'
#' ## convert original genotype
#' inbred_gen <- convert(input_geno, type = 'hmp2')
#'
#' ##additive model infer the additive genotypes of hybrids
#' gena <- infergen(inbred_gen, hybrid_phe)$add
#'
#' ##additive model
#' R2<-cv(fix=NULL,gen=gena,y=hybrid_phe[,3],method ='GBLUP',nfold=5,nTimes=1,seed=1234,CPU=1)}
#' @export
cv <- function(fix = NULL, gen, y, method = "GBLUP", drawplot = TRUE, nfold = 5, nTimes = 1, seed = 1234, CPU = 1) {
    cv.GBLUP <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by GBLUP...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        kk <- list(kin(gen))
        n <- length(y)
        y <- as.matrix(y)
        if (is.null(fix)) {
            fix <- matrix(1, n, 1)
        } else {
            fix <- as.matrix(fix)
        }
        yobs <- NULL
        yhat <- NULL
        fold <- NULL
        id <- NULL
        k11 <- list()
        k21 <- list()
        g <- length(kk)
        cl.cores <- detectCores()
        if (cl.cores <= 2 || CPU <= 1) {
            cl.cores <- 1
        } else if (cl.cores > 2) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("Maize6KGSP")) %dopar% {
            i1 <- which(foldid != k)
            i2 <- which(foldid == k)
            x1 <- fix[i1, , drop = F]
            y1 <- y[i1, , drop = F]
            x2 <- fix[i2, , drop = F]
            y2 <- y[i2, , drop = F]
            for (i in 1:g) {
                k11[[i]] <- kk[[i]][i1, i1]
                k21[[i]] <- kk[[i]][i2, i1]
            }
            parm <- mixed(fix = x1, y = y1, kk = k11)
            G21 <- 0
            for (i in 1:g) {
                G21 <- G21 + k21[[i]] * parm$var[i]
            }
            v_i <- parm$v_i
            beta <- parm$beta
            y3 <- x2 %*% beta + G21 %*% v_i %*% (y1 - x1 %*% beta)
            yobs <- y2
            yhat <- y3
            data.frame(yobs, yhat)
        }
        stopCluster(cl)
        R2 <- cor(res$yobs, res$yhat)^2
        print("Predict by GBLUP...ended.")
        return(R2)
    }
    cv.bayesb <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by BayesB...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        if (!requireNamespace("BGLR", quietly = TRUE)) {
            stop("BGLR needed for this function to work. Please install it.", call. = FALSE)
        }
        x <- gen
        if (is.null(fix)) {
            eta <- list(list(X = x, model = "BayesB"))
        } else {
            eta <- list(list(X = fix, model = "FIXED"), list(X = x, model = "BayesB"))
        }
        yhat <- NULL
        yobs <- NULL
        cl.cores <- detectCores()
        if (cl.cores <= 2 || CPU <= 1) {
            cl.cores <- 1
        } else if (cl.cores > 2) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("BGLR")) %dopar% {
            yNa <- y
            whichNa <- which(foldid == k)
            yNa[whichNa] <- NA
            fm <- BGLR(y = yNa, ETA = eta, verbose = F)
            yhat <- fm$yHat[whichNa]
            yobs <- y[whichNa]
            data.frame(yobs, yhat)
        }
        stopCluster(cl)
        pr2 <- cor(res$yobs, res$yhat)^2
        print("Predict by BayesB...ended.")
        return(pr2)
    }
    cv.rkhsmk <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by RKHS...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        x <- gen
        if (is.null(fix)) {
            fix <- matrix(1, n, 1)
        } else {
            fix <- as.matrix(fix)
        }
        X <- scale(x, center = TRUE, scale = TRUE)
        D <- (as.matrix(dist(X, method = "euclidean"))^2)/ncol(X)
        h <- 0.5 * c(1/5, 1, 5)
        if (is.null(fix)) {
            ETA <- list(list(K = exp(-h[1] * D), model = "RKHS"), list(K = exp(-h[2] * D), model = "RKHS"), list(K = exp(-h[3] *
                D), model = "RKHS"))
        } else {
            ETA <- list(list(K = exp(-h[1] * D), model = "RKHS"), list(K = exp(-h[2] * D), model = "RKHS"), list(K = exp(-h[3] *
                D), model = "RKHS"), list(X = fix, model = "FIXED"))
        }
        yhat <- NULL
        yobs <- NULL
        cl.cores <- detectCores()
        if (cl.cores <= 2) {
            cl.cores <- 1
        } else if (cl.cores > 2 || CPU <= 1) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("BGLR")) %dopar% {
            yNa <- y
            whichNa <- which(foldid == k)
            yNa[whichNa] <- NA
            fm <- BGLR(y = yNa, ETA = ETA, verbose = F)
            yhat <- fm$yHat[whichNa]
            yobs <- y[whichNa]
            data.frame(yobs, yhat)
        }
        stopCluster(cl)
        pr2 <- cor(res$yobs, res$yhat)^2
        print("Predict by RKHS...ended.")
        return(pr2)
    }
    cv.lasso <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by LASSO...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        if (!requireNamespace("glmnet", quietly = TRUE)) {
            stop("glmnet needed for this function to work. Please install it.", call. = FALSE)
        }
        x <- gen
        z <- cbind(fix, x)
        yyhat <- NULL
        yyobs <- NULL
        cl.cores <- detectCores()
        if (cl.cores <= 2 || CPU <= 1) {
            cl.cores <- 1
        } else if (cl.cores > 2) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("glmnet")) %dopar% {
            iindex <- which(foldid == k)
            xx <- z[-iindex, ]
            yy <- y[-iindex]
            fit0 <- cv.glmnet(x = xx, y = yy)
            lambda <- fit0$lambda.min
            ffit <- glmnet(x = xx, y = yy, lambda = lambda)
            tmp <- predict(ffit, newx = z[iindex, ])
            yyhat <- as.numeric(tmp)
            yyobs <- as.numeric(as.matrix(y[iindex]))
            data.frame(yyhat, yyobs)
        }
        stopCluster(cl)
        pr2 <- cor(res$yyobs, res$yyhat)^2
        print("Predict by LASSO...ended.")
        return(pr2)
    }
    cv.xgboost <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by XGBoost...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        if (!requireNamespace("xgboost", quietly = TRUE)) {
            stop("xgboost needed for this function to work. Please install it.", call. = FALSE)
        }
        x <- gen
        z <- cbind(fix, x)
        yp <- NULL
        yo <- NULL
        cl.cores <- detectCores()
        if (cl.cores <= 2 || CPU <= 1) {
            cl.cores <- 1
        } else if (cl.cores > 2) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("xgboost")) %dopar% {
            id1 <- which(foldid != k)
            id2 <- which(foldid == k)
            x1 <- z[id1, ]
            x2 <- z[id2, ]
            y1 <- y[id1]
            y2 <- y[id2]
            xg <- xgboost(x = x1, y = y1, colsample_bytree = 0.9, learning_rate = 0.02, min_child_weight = 11,
            nrounds = 1150, subsample = 0.8, nthreads = 4,seed=123,verbosity = 0)
            yhat <- predict(xg, x2)
            yp <- yhat
            yo <- y2
            data.frame(yp, yo)
        }
        stopCluster(cl)
        pr2 <- cor(res$yo, res$yp)^2
        print("Predict by XGBoost...ended.")
        return(pr2)
    }
    cv.pls <- function(fix, gen, y, nfold, seed, CPU) {
        print("Predict by PLS...")
        set.seed(seed + time)
        foldid <- sample(rep(1:nfold, ceiling(n/nfold))[1:n])
        if (!requireNamespace("pls", quietly = TRUE)) {
            stop("pls needed for this function to work. Please install it.", call. = FALSE)
        }
        x <- gen
        z <- cbind(fix, x)
        yp <- NULL
        yo <- NULL
        cl.cores <- detectCores()
        if (cl.cores <= 2 || CPU <= 1) {
            cl.cores <- 1
        } else if (cl.cores > 2) {
            if (cl.cores > 10) {
                cl.cores <- 10
            } else {
                cl.cores <- detectCores() - 1
            }
        }
        cl <- makeCluster(cl.cores)
        registerDoParallel(cl)
        res <- foreach(k = 1:nfold, .multicombine = TRUE, .combine = "rbind", .packages = c("pls")) %dopar% {
            id1 <- which(foldid != k)
            id2 <- which(foldid == k)
            x1 <- z[id1, ]
            x2 <- z[id2, ]
            y1 <- y[id1]
            y2 <- y[id2]
            pls.fit <- plsr(y1 ~ x1, ncomp = 5, validation = "CV")
            nn <- as.numeric(which.min(tt <- RMSEP(pls.fit)$val[1, , ][-1]))
            yhat <- predict(pls.fit, newdata = x2, ncomp = nn)
            yp <- as.numeric(yhat)
            yo <- y2
            data.frame(yp, yo)
        }
        stopCluster(cl)
        pr2 <- cor(res$yo, res$yp)^2
        print("Predict by PLS...ended.")
        return(pr2)
    }
    cvres <- NULL
    cvres <- list(cvres)
    k <- NULL
    for (time in 1:nTimes) {
        cat(time)
        n <- length(y)
        if ((method == "GBLUP") | (method == "BayesB") | (method == "RKHS") | (method == "PLS") | (method == "LASSO") |
            (method == "XGBoost") | (method == "ALL")) {
            if (method == "GBLUP") {
                cvres[[time]] <- cv.GBLUP(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "BayesB") {
                cvres[[time]] <- cv.bayesb(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "RKHS") {
                cvres[[time]] <- cv.rkhsmk(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "LASSO") {
                cvres[[time]] <- cv.lasso(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "XGBoost") {
                cvres[[time]] <- cv.xgboost(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "PLS") {
                cvres[[time]] <- cv.pls(fix, gen, y, nfold, seed, CPU)
            }
            if (method == "ALL") {
                print("Predict by ALL...")
                GBLUP <- cv.GBLUP(fix, gen, y, nfold, seed, CPU)
                BayesB <- cv.bayesb(fix, gen, y, nfold, seed, CPU)
                RKHS <- cv.rkhsmk(fix, gen, y, nfold, seed, CPU)
                LASSO <- cv.lasso(fix, gen, y, nfold, seed, CPU)
                XGBoost <- cv.xgboost(fix, gen, y, nfold, seed, CPU)
                PLS <- cv.pls(fix, gen, y, nfold, seed, CPU)
                cvres[[time]] <- cbind(GBLUP, BayesB, RKHS, PLS, LASSO, XGBoost)
                print("Predict by ALL...ended.")
            }
        } else {
            stop("Please choose a predict method: GBLUP, BayesB, RKHS, PLS, LASSO,  XGBoost.")
        }
    }
    res <- do.call(rbind, cvres)

    if (method == "ALL" & drawplot == TRUE) {
        mycolor <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F")
        plotres <- function(d) {
            names <- attr(d, "dimnames")[[2]]
            attr(d, "dimnames") <- NULL
            d <- as.matrix(d)
            d <- apply(d, 2, mean)
            barplot(height = d, names.arg = names, col = mycolor, las = 2, ylim = c(0, 0.3), xlim = c(0, 10), main = "Trait predictability of 8 methods",
                ylab = "R2")
            locat <- seq(0.75, 9, length.out = 8)
            text(locat, d + 0.015, round(d, 3), cex = 0.9)
        }
        plotres(res)
    }
    return(res)
}

