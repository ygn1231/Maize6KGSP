# * Author:    Yang.Xu 
# * Created:   11:40 PM Monday, 27 April 2021
# * Copyright: AS IS
#' @importFrom stats cor dist optim predict na.omit var cov 
#' @importFrom pls plsr RMSEP MSEP mvrValstats
#' @importFrom BGLR BGLR
#' @importFrom glmnet cv.glmnet glmnet 
#' @importFrom xgboost xgboost 
#' @importFrom doParallel registerDoParallel
#' @importFrom parallel detectCores makeCluster stopCluster
#' @importFrom foreach %dopar% foreach
#' @importFrom graphics barplot text
#' @importFrom data.table fread
#' @importFrom DT renderDataTable datatable dataTableOutput
#' @importFrom shiny addResourcePath tags HTML h2 h3 h4 column actionLink
#' @importFrom shiny helpText selectInput fileInput sliderInput checkboxInput
#' @importFrom shiny textInput downloadLink radioButtons conditionalPanel code
#' @importFrom shiny hr numericInput actionButton reactive req downloadHandler
#' @importFrom shiny reactiveVal observeEvent updateNavbarPage shinyApp
#' @importFrom shiny fluidPage navbarPage tabPanel fluidRow navlistPanel uiOutput renderUI
#' @importFrom utils write.csv

NULL
