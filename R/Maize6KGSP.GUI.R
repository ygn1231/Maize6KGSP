#' @title Graphical User Interface for R package Maize6KGSP
#' @description Graphical User Interface for cross validation, genotype conversion and hybrid performance prediction.
#' @return No return value, called for Graphical User Interface
#' @examples
#' {
#' Maize6KGSP.GUI()}
#' @export

Maize6KGSP.GUI <- function() {
  www_path <- system.file("www", package = "Maize6KGSP")
  shiny::addResourcePath(
    prefix = "res",
    directoryPath = www_path
  )
  
  if (interactive()) {
    ui <- fluidPage(
      
      tags$style(HTML("
        /* 1. Navbar container: fixed height + line height (basis for vertical centering) */
          .navbar-default {
            height: 50px; /* Navbar height, adjustable (e.g., 60px) */
            line-height: 50px; /* Line height = height, single line text vertical centering automatically */
            }

           /* 2. Navbar tags (li>a): clear default padding + inherit line height */
          .navbar-default .navbar-nav > li > a {
           padding-top: 0 !important; /* Clear default top padding */
           padding-bottom: 0 !important; /* Clear default bottom padding */
           display: inline-block; /* Ensure line height takes effect */
           vertical-align: middle; /* Compatible with browser vertical alignment */
            height: 100%; /* Occupy full navbar height */
           line-height: inherit; /* Inherit navbar line height */
          }

         /* 3. Active/hover state tags: keep consistent height and line height to avoid offset */
         .navbar-default .navbar-nav > .active > a,
           .navbar-default .navbar-nav > li > a:hover {
          height: 100%;
           line-height: 50px; /* Consistent with navbar line height */
          }
         
        #introduction-panel {
            background-color: #f8fbf9;
            font-family: Arial, sans-serif;
            padding: 20px 0;
          }
        
        /* 1. Overall navbar background (light blue) */
        .navbar-default {
          background-color: #e3f2fd !important;  /* Main light blue background */
          border-color: #bbdefb !important;       /* Border light blue */
          box-shadow: 0 2px 4px rgba(0,0,0,0.1); /* Slight shadow to enhance layering */
        }
        /* Navbar tags (inactive state) */
        .navbar-default .navbar-nav > li > a {
          color: #002171 !important;
          font-size: 16px;
          padding: 15px 20px;
        }
        /* 3. Navbar tags (hover/active state) */
        .navbar-default .navbar-nav > .active > a,
        .navbar-default .navbar-nav > li > a:hover {
          background-color: #bbdefb !important;  /* Hover/active state light blue (darker than background) */
          color: #002171 !important;             /* Darker blue text */
          border-radius: 5px;                    /* Rounded corners */
        }
        /* Feature tag jump link style (remove underline + hand cursor) */
        .feature-link {
          text-decoration: none;
          color: inherit;
          display: block;  /* Occupy full tag area for larger click range */
          width: 100%;
          height: 100%;
        }
        .core-feature-tag {
          cursor: pointer;  /* Hand cursor */
          transition: background-color 0.3s ease; /* Transition animation */
        }
        .core-feature-tag:hover {
          background-color: #81c784 !important; /* Darker color on hover */
        }
      ")),
      navbarPage(
        title = h4(' '),
        id = "main_navbar",  # Navbar ID for jump control
        # Home page
        tabPanel(
          title = h4('home'),
          # 1. Style optimization: scope limitation + responsive design
          tags$style(HTML("
           /* Styles only for home tab (avoid global pollution) */
           #introduction-panel {
             background-color: #f8fbf9;
             font-family: Arial, sans-serif;
             padding: 20px 0;
          }
          /* Title style */
          #introduction-panel .page-title {
            color: #2e7d32;
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 15px;
          }
          #introduction-panel .page-subtitle {
            color: #558b2f;
            font-size: 20px;
            margin-bottom: 5px;
          }
          #introduction-panel .page-content {
            color: #558b2f;
            font-size: 16px;
            margin-bottom: 10px;
          }
          
          
          /* Left feature icon area - responsive adaptation for small screens */
          #introduction-panel .feature-icon {
            text-align: center;
            margin-bottom: 20px;
             margin-left: auto;
            margin-right: auto;
             max-width: 200px;  
          }
          #introduction-panel .feature-icon img {
            width: 240px;
            height: 240px;
            margin-bottom: 20px;
            /* Core optimization for local image clarity: anti-aliasing + HD rendering */
            image-rendering: -webkit-optimize-contrast; /* Chrome/Safari adaptation */
            image-rendering: crisp-edges; /* Universal HD, retain local image edge details */
             -webkit-backface-visibility: hidden; /* Solve local image blurriness in Chrome */
            backface-visibility: hidden;
            transform: translateZ(0); /* Hardware acceleration to improve local image rendering clarity */
            /* Local image centering fallback */
            display: block;
            margin-left: auto;
            margin-right: auto;
           /* Optional: avoid layout disorder when local image fails to load */
            object-fit: cover; /* Keep image ratio without stretching deformation */
          }
          #introduction-panel .feature-icon p {
            color: #2e7d32;
            font-size: 14px;
            margin: 20px 0;
          }
          /* Middle core feature tags */
          #introduction-panel .core-feature-tag {
            background-color: #a5d6a7;
            color: #2e7d32;
            padding: 8px 15px;
            border-radius: 20px;
            margin: 5px;
            display: inline-block;
            font-size: 14px;
          }
          #introduction-panel .core-feature-tag.highlight {
            background-color: #81c784;
            font-weight: bold;
          }
          
        ")),
          
          # 2. Page content container (add ID for style isolation)
          tags$div(id = "introduction-panel",
                   # Top title row
                   fluidRow(
                     column(
                       style = "margin-top: 50px;",
                       width = 12,
                       align = "center",
                       tags$div(class = "page-title", "Maize6K-GS Array-Based Genomic Prediction Platform"),
                       tags$div(class = "page-subtitle", "Introduction"),
                       tags$div(class ="page-content","Based on the Maize6K-GS array and GS intelligent breeding platform, users can import parental genotypic and hybrid phenotypic data for the platform to infer F₁ genotypes and perform phenotypic prediction. Preloaded with training population datasets, the platform enables integration with its native data upon input of maize6K-GS derived genotyping data, thus facilitating breeding resource sharing and utilization. This collaborative  array-platform solution significantly cuts the time and costs of maize GS breeding.
 ")
                     )
                   ),
                   
                   # Core content row (three columns)
                   fluidRow(
                     # Left: Feature icon area (add class for responsiveness)
                     column(
                       width = 3,
                       align = "center",
                       class = "feature-col",
                       style = "margin-top: 50px;",
                       # Feature icon 2
                       tags$div(class = "feature-icon",
                                tags$img(src = "res/fig2.png", width = "100px", height = "100px"),
                                tags$p("")
                       )
                     ),
                     
                     # Middle: Core feature area (add jump function)
                     column(
                       width = 6,
                       align = "center",
                       class = "core-col",
                       tags$div(style = "margin-bottom: 15px; font-size: 18px;", "Core Features"), # Enlarge title
                       # Grid container: two-column layout + unified alignment
                       tags$div(
                         style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; width: 100%; max-width: 600px; margin: 0 auto;",
                         # First column (first 3 functions with jump)
                         tags$div(style = "display: flex; flex-direction: column; gap: 10px;",
                                  # Function 1: Genotype data conversion → jump to Genotype tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_geno_conversion",
                                             label = "Genotype data input & conversion                   ",
                                             class = "feature-link"
                                           )
                                  ),
                                  # Function 2: Hybrid genotype infergen → jump to HybridGeno tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_hybrid_geno",
                                             label = "Hybrid genotype inference",
                                             class = "feature-link"
                                           )
                                  ),
                                  # Function 3: snp match → jump to SNPMatch tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_geno_int",
                                             label = "Genotype data integration                              ",
                                             class = "feature-link"
                                           )
                                  )
                         ),
                         # Second column (last 3 functions with jump)
                         tags$div(style = "display: flex; flex-direction: column; gap: 10px;",
                                  # Function 4: Evaluation of predictability → jump to PredictEval tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_predict_eval",
                                             label = "Predictability evaluation",
                                             class = "feature-link"
                                           )
                                  ),
                                  # Function 5: Prediction of hybrid phenotype → jump to HybridPheno tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_hybrid_phe",
                                             label = "Hybrid phenotype prediction",
                                             class = "feature-link"
                                           )
                                  ),
                                  # Function 6: Prediction of phenotype → jump to PhenoPred tab
                                  tags$div(class = "core-feature-tag highlight", style = "width: 100%; height: 80px; font-size: 16px; padding: 10px; display: flex; align-items: center; justify-content: center; text-align: center; box-sizing: border-box;",
                                           actionLink(
                                             inputId = "link_pheno_pred",
                                             label = "Unknown population phenotype prediction",  # Simplify to plain text, remove nested tags
                                             class = "feature-link"
                                           )
                                  )
                         )
                       )
                     )
                   )
          )
        ),
        
        # Target tabs for jump (one-to-one correspondence with functions)
        tabPanel(title ='convert', navlistPanel(widths = c(3,9),
                                                tabPanel(h2('Convert Genotype'),
                                                         title = 'Description',
                                                         helpText('Convert genotypes in HapMap format ,VCF format or in numeric format for hybrid package.')),
                                                tabPanel(h2('Input genotype'),
                                                         title = 'Input files',
                                                         fluidRow(
                                                           column(width = 5,
                                                                  selectInput('geno_type', label=h4('type'),
                                                                              choices = list('HapMap format with single bit'='hmp1',
                                                                                             'HapMap format with double bit'='hmp2',
                                                                                             "vcf format" = "vcf",
                                                                                             'numeric format'='num'))),
                                                           column(width = 8,
                                                                  helpText('The type of genotype. There are four options: "hmp1" for HapMap single bit, "hmp2" for HapMap double bit, "vcf" for VCF format, and "num" for numeric format.'))),
                                                         fluidRow(
                                                           column(width = 5,
                                                                  fileInput(
                                                                    'geno_path',  # Keep ID consistency for compatibility with subsequent processing logic
                                                                    label = h4('Select genotype file'),
                                                                    multiple = FALSE,  # Only allow single file selection
                                                                    accept = c('.hmp', '.txt', '.vcf', '.csv', '.tsv'),  # Restrict supported file formats
                                                                    width = '100%',
                                                                    buttonLabel = 'Browse...',  # Browse button text
                                                                    placeholder = 'No file selected'  # Prompt when no file is selected
                                                                  )),
                                                           column(width = 8,
                                                                  helpText('Supported formats: .hmp, .txt, .vcf, .csv, .tsv.')
                                                           ))),
                                                tabPanel(h2('Parameters for SNPs'),
                                                         title = 'Parameters',
                                                         fluidRow(
                                                           column(width = 4,
                                                                  sliderInput('missingrate', label=h4('missingrate'),
                                                                              min=0, max=0.3, value=0.2)),
                                                           column(width = 8,
                                                                  helpText('max missing percentage for each SNP, default is 0.2.'))),
                                                         fluidRow(
                                                           column(width = 4,
                                                                  sliderInput('maf', label=h4('maf'),
                                                                              min=0, max=0.2, value=0.05)),
                                                           column(width = 8,
                                                                  helpText('minor allele frequency for each SNP, default is 0.05.'))),
                                                         fluidRow(
                                                           column(width = 4,
                                                                  checkboxInput('impute', label='Impute', value = TRUE)),
                                                           column(width = 8,
                                                                  helpText('logical. If TRUE, imputation. Default is TRUE.'))),
                                                         fluidRow(
                                                           column(width = 4,
                                                                  textInput(
                                                                    'dir_path',  # Input ID for server to get directory path
                                                                    label = h4('dir'),
                                                                    placeholder = 'Demo：D:/results/genotype_output'  # Directory path example
                                                                  )),
                                                           column(width = 8,
                                                                  helpText('This file is for the input path.When type= "vcf", it must be provided, default is NULL.')
                                                           ))),
                                                tabPanel(h4('Converted genotype'),
                                                         title = 'Results',
                                                         fluidRow(column(width=6,actionButton('calculate_num', label = h4('Run Genotype data conversion'), 
                                                                                              style = "background-color: #4CAF50; color: white;"))),
                                                         fluidRow(
                                                           column(width=12, DT::dataTableOutput('convertview'))),
                                                         fluidRow(
                                                           column(width=6, downloadLink('convered', label=h4('Download genotype')))))),h3("")),
        tabPanel(title = 'infergen',navlistPanel(widths = c(3,9), tabPanel(h2('Infer Genotype of Hybrids'),
                                                                           title = 'Description',
                                                                           helpText('Infer additive  genotypes of hybrids based on their parental genotypes.')),
                                                 tabPanel(h2('Input inbred genotype'),
                                                          title='Genotype Input',
                                                          fluidRow(
                                                            column(width=4,
                                                                   radioButtons('inbred_gen_source', label = h4('Inbred Genotype Source'),
                                                                                choices = list('Upload file' = 'upload', 'Use convert result' = 'convert'),
                                                                                selected = 'upload')),
                                                            column(width=8,
                                                                   helpText('Choose inbred genotype source: upload your own file, or use converted inbredgen from convert module.'))
                                                          ),
                                                          # Conditional panel: show file upload when upload is selected (original logic)
                                                          fluidRow(
                                                            conditionalPanel(
                                                              condition = 'input.inbred_gen_source == "upload"',
                                                              column(width=4,fileInput('inbred_gen_upload',label = h4('inbred_gen'))),
                                                              column(width=8,helpText('A matrix for genotypes of parental lines in numeric format, coded as 1, 0 and
          -1. The row.names of inbred_gen must be provied. It can be obtained from the original genotype using',code('convert'),'function'))
                                                            )
                                                          ),
                                                          # Conditional panel: prompt to use conversion result when convertgen is selected
                                                          fluidRow(
                                                            conditionalPanel(
                                                              condition = 'input.inbred_gen_source == "convert"',
                                                              column(width=12,
                                                                     helpText(HTML('<span style="color:blue;">Using converted inbredgen from convert module. Please run convert first!</span>')))
                                                            )
                                                          )),
                                                 tabPanel(h2('Crosses to be genotyped'),
                                                          title = 'Input crosses',
                                                          fluidRow(
                                                            column(width = 4,
                                                                   fileInput('crosses', label = h4('crosses'))),
                                                            column(width=8,
                                                                   helpText('a data frame with two columns. The first column and the second column respectively are the names of male and female parents of the corresponding hybrids.')),
                                                          )),
                                                 tabPanel(h4('Genotype of hybrids'),
                                                          title = 'Results',
                                                          fluidRow(
                                                            column(width=6,
                                                                   actionButton('calculate_infered', label = h4('Run Hybrid genotype inference'), 
                                                                                style = "background-color: #4CAF50; color: white;"))),
                                                          fluidRow(
                                                            column(width=12, DT::dataTableOutput('infergenview'))),
                                                          fluidRow(
                                                            column(width=6, downloadLink('inferened', label=h4('Download genotype of hybrids')))))),h3("")),
        
        tabPanel(title = 'geno_int', navlistPanel(widths = c(3,9),
                                                  tabPanel(h2('Genotype data integration'),
                                                           title = 'Description',
                                                           helpText('Match the genotypic data of the training population and breeding population, ensuring consistency of markers.')),
                                                  tabPanel(h2('Input training and breeding population genotypes'),
                                                           title = 'Input files',
                                                           fluidRow(
                                                             column(width = 4,
                                                                    selectInput('geno_type', label=h4('type'),
                                                                                choices = list('HapMap format with single bit'='hmp1',
                                                                                               'HapMap format with double bit'='hmp2',
                                                                                               "vcf format" = "vcf",
                                                                                               'numeric format'='num'))),
                                                             column(width = 8,
                                                                    helpText('The type of genotype. There are four options: "hmp1" for HapMap single bit,
                           "hmp2" for HapMap double bit, "vcf" for VCF format,
                           and "num" for numeric format.'))),
                                                           hr(),
                                                           fluidRow(
                                                             column(width = 4,
                                                                    fileInput(
                                                                      inputId = 'train_geno_path',  # Input ID: train_geno
                                                                      label = h4('Training population genotype file'),
                                                                      multiple = FALSE,  # Only allow single file selection
                                                                      accept = c('.hmp', '.txt', '.vcf', '.csv', '.tsv'),  # Restrict supported file formats
                                                                      width = '100%',
                                                                      buttonLabel = 'Browse...',  # Browse button text
                                                                      placeholder = 'No file selected'  # Prompt when no file is selected
                                                                    )),
                                                             column(width = 8,
                                                                    helpText('Supported formats: .hmp, .txt, .vcf, .csv, .tsv.')
                                                             )
                                                           ),
                                                           fluidRow(
                                                             column(width = 4,
                                                                    fileInput(
                                                                      inputId = 'breed_geno_path',  # Input ID: train_geno
                                                                      label = h4('Breedind population genotype file'),
                                                                      multiple = FALSE,  # Only allow single file selection
                                                                      accept = c('.hmp', '.txt', '.vcf', '.csv', '.tsv'),  # Restrict supported file formats
                                                                      width = '100%',
                                                                      buttonLabel = 'Browse...',  # Browse button text
                                                                      placeholder = 'No file selected'  # Prompt when no file is selected
                                                                    )),
                                                             column(width = 8,
                                                                    helpText('Supported formats: .hmp, .txt, .vcf, .csv, .tsv.')
                                                             )
                                                           )
                                                  ),
                                                  tabPanel(h2('Input Crosses Name, Training Population and Breeding Population'),
                                                           title='Optional Input',
                                                           fluidRow(
                                                             column(width=4,
                                                                    radioButtons('traincrossinput', label = h4('crosses name (training population, optional)'),
                                                                                 c('Not included'='NULL','Input a train crosses'='input'))),
                                                             column(width=8,
                                                                    conditionalPanel(condition = 'input.traincrossinput=="input"',
                                                                                     fileInput('train_crosses', label=h4('crosses name'))))),
                                                           fluidRow(
                                                             column(width=4,
                                                                    radioButtons('breedcrossinput', label = h4('crosses name (breeding population, optional)'),
                                                                                 c('Not included'='NULL','Input a breed crosses'='input'))),
                                                             column(width=8,
                                                                    conditionalPanel(condition = 'input.breedcrossinput=="input"',
                                                                                     fileInput('breed_crosses', label=h4('crosses name')))))),
                                                  tabPanel(h2('Parameters for SNPs'),
                                                           title = 'Parameters',
                                                           fluidRow(
                                                             column(width = 4,
                                                                    sliderInput('missingrate', label=h4('missingrate'),
                                                                                min=0, max=0.3, value=0.2)),
                                                             column(width = 8,
                                                                    helpText('max missing percentage for each SNP, default is 0.2.'))),
                                                           fluidRow(
                                                             column(width = 4,
                                                                    sliderInput('maf', label=h4('maf'),
                                                                                min=0, max=0.2, value=0.05)),
                                                             column(width = 8,
                                                                    helpText('minor allele frequency for each SNP, default is 0.05.'))),
                                                           fluidRow(
                                                             column(width = 4,
                                                                    checkboxInput('impute', label='Impute', value = TRUE)),
                                                             column(width = 8,
                                                                    helpText('logical. If TRUE, imputation. Default is TRUE.'))),
                                                           fluidRow(
                                                             column(width = 4,
                                                                    textInput(
                                                                      'dir_path',  # Input ID for server to get directory path
                                                                      label = h4('dir'),
                                                                      placeholder = 'Demo：D:/results/genotype_output'  # Directory path example
                                                                    )),
                                                             column(width = 8,
                                                                    helpText('This file is for the input path.When type= "vcf", it must be provided, default is NULL.')
                                                             ))),
                                                  tabPanel(
                                                    h4('Matched genotype'),
                                                    title = 'Results',
                                                    fluidRow(
                                                      column(width=6,
                                                             actionButton('calculate_match', label = h4('Run Genotype data integration'), 
                                                                          style = "background-color: #4CAF50; color: white;"))),
                                                    # Part 1: Training genotype (train_geno) display + download
                                                    fluidRow(
                                                      column(
                                                        width = 12,
                                                        h4("✅ Training Genotype (train_geno)"),  # Distinguish title for intuitiveness
                                                        DT::dataTableOutput('match_train_geno_view')    # Training set table (new ID)
                                                      )
                                                    ),
                                                    fluidRow(
                                                      column(
                                                        width = 6,
                                                        downloadLink('download_train_geno', label = h4('Download train genotype'))  # Training set download (new ID)
                                                      )
                                                    ),
                                                    # Separator: distinguish two results for better visualization
                                                    hr(style = "border-top: 2px solid #ccc; margin: 20px 0;"),
                                                    # Part 2: Breeding genotype (breed_geno) display + download
                                                    fluidRow(
                                                      column(
                                                        width = 12,
                                                        h4("✅ Breeding Genotype (breed_geno)"), # Distinguish title
                                                        DT::dataTableOutput('match_breed_geno_view')   # Breeding set table (new ID)
                                                      )
                                                    ),
                                                    fluidRow(
                                                      column(
                                                        width = 6,
                                                        downloadLink('download_breed_geno', label = h4('Download breed genotype')) # Breeding set download (new ID)
                                                      )))),h3("")),
        
        tabPanel(title = 'cv', navlistPanel(widths = c(3,9),
                                            tabPanel(h2('Evaluate Trait Predictability via Cross Validation'),
                                                     title = 'Description',
                                                     helpText('The cv function evaluates trait predictability based on six GS methods via k-fold cross validation. The trait predictability is defined as the squared Pearson correlation coefficient between the observed and the predicted trait values.')),
                                            tabPanel(h2('Input genotype & phenotype'),
                                                     title='Input files',
                                                     fluidRow(
                                                       # New: Select genotype source
                                                       column(width=4,
                                                              radioButtons('geno_source', label = h4('Genotype Source'),
                                                                           choices = list('Upload file' = 'upload',
                                                                                          'Use infergen result' = 'infergen'),
                                                                           selected = 'upload')),
                                                       column(width=8,
                                                              helpText('Choose genotype source: upload your own file, or use the hybrid genotype inferred by infergen module.'))),
                                                     # Conditional panel: show file upload when upload is selected
                                                     fluidRow(
                                                       conditionalPanel(
                                                         condition = 'input.geno_source == "upload"',
                                                         column(width=4,
                                                                fileInput('inbred_gen_upload', label = h4('genotype'), multiple = TRUE)),
                                                         column(width = 8,
                                                                helpText('A matrix for genotypes of parental lines in numeric format, coded as 1, 0 and -1. The row.names of inbred_gen must be provided. It can be obtained from the original genotype using', code('convert'), 'function')))),
                                                     # Conditional panel: prompt to use inference result when infergen is selected
                                                     fluidRow(
                                                       conditionalPanel(
                                                         condition = 'input.geno_source == "infergen"',
                                                         column(width=12,
                                                                helpText(HTML('<span style="color:blue;">Using hybrid genotype inferred from infergen module. Please run infergen first!</span>'))))),
                                                     hr(), # Separator
                                                     fluidRow(
                                                       column(width = 4,
                                                              fileInput('cv_phenotype', label = h4('y'))),
                                                       column(width = 4,uiOutput("select_target_trait1")),
                                                       column(width=8,
                                                              helpText('The phenotypic values of individuals.The names of individuals must match the rownames genotype data. Missing (NA) values are not allowed.')),
                                                       fluidRow(
                                                         column(
                                                           width = 12,
                                                           h4("Filtered phenotype data preview"),
                                                           dataTableOutput("cv_filtered_phenotype_table")
                                                         )))),
                                            tabPanel(h2('Input design matrix of the fixed effects'),
                                                     title='Optional Input',
                                                     fluidRow(
                                                       column(width=4,
                                                              radioButtons('cvfixinput', label = h4('design matrix of the fixed effects(Optional)'),
                                                                           c('Not included'='NULL','Input a design matrix'='input'))),
                                                       column(width=8,
                                                              conditionalPanel(condition = 'input.cvfixinput=="input"',
                                                                               fileInput('fix', label=h4('fixed effects')))))),
                                            tabPanel(h2('Select models & other parameters'),
                                                     title = 'Parameters',
                                                     fluidRow(
                                                       column(width=6,
                                                              selectInput('cvmethod', label=h4('method'),
                                                                          choices = list('GBLUP'='GBLUP','BayesB'='BayesB',
                                                                                         'RKHS'='RKHS',
                                                                                         'LASSO'='LASSO','PLS'='PLS',
                                                                                         'XGBoost'='XGBoost','ALL'='ALL'),
                                                                          selected = 'GBLUP'))),
                                                     fluidRow(
                                                       column(width=6,
                                                              numericInput('nfold', label=h4('the number of folds'), value = 5))),
                                                     fluidRow(
                                                       column(width=4,
                                                              numericInput('ntimes', label=h4('replicates'), value = 1)),
                                                       column(width=4,
                                                              numericInput('cvseed', label=h4('the random number'), value = 133))),
                                                     fluidRow(
                                                       column(width=4,
                                                              numericInput('CPU', label=h4('the number of CPU'), value = 1)))),
                                            tabPanel(h2('Trait predictability (R^2)'),
                                                     title = 'CV Results',
                                                     fluidRow(
                                                       column(width=6,
                                                              actionButton('calculate_cv', label = h4('Run Predictability evaluation'), 
                                                                           style = "background-color: #4CAF50; color: white;"))),
                                                     fluidRow(
                                                       column(width=12, DT::dataTableOutput('cvres1'))),
                                                     fluidRow(
                                                       column(width=6, downloadLink('cvres2', label=h4('Download CV Results')))))),h3("")),
        
        tabPanel(title = 'hybrid_predict', navlistPanel(widths = c(3,9),
                                                        tabPanel(h2('Predict the Performance of Hybrids'),title = 'Description',
                                                                 helpText('Predict all potential crosses of a given set of parents using a subset of crosses as the training sample.')),
                                                        tabPanel(h2('Input genotype & phenotype'),title = 'Input files',
                                                                 fluidRow(
                                                                   column(width=4,
                                                                          radioButtons('inbred_gen_source', label = h4('Inbred Genotype Source'),
                                                                                       choices = list('Upload file' = 'upload', 'Use convert result' = 'convertgen'),
                                                                                       selected = 'upload')),
                                                                   column(width=8,
                                                                          helpText('Choose inbred genotype source: upload your own file, or use converted inbredgen from convertgen module.'))
                                                                 ),
                                                                 # Conditional panel: show file upload when upload is selected (original logic)
                                                                 fluidRow(
                                                                   conditionalPanel(
                                                                     condition = 'input.inbred_gen_source == "upload"',
                                                                     column(width=4,fileInput('inbred_gen_upload',label = h4('inbred_gen'))),
                                                                     column(width=8,helpText('A matrix for genotypes of parental lines in numeric format, coded as 1, 0 and
          -1. The row.names of inbred_gen must be provied. It can be obtained from the original genotype using',code('convert'),'function'))
                                                                   )
                                                                 ),
                                                                 # Conditional panel: prompt to use conversion result when convert is selected
                                                                 fluidRow(
                                                                   conditionalPanel(
                                                                     condition = 'input.inbred_gen_source == "convert"',
                                                                     column(width=12,
                                                                            helpText(HTML('<span style="color:blue;">Using converted inbredgen from convert module. Please run convert first!</span>')))
                                                                   )
                                                                 ),
                                                                 hr(), 
                                                                 fluidRow(column(width = 4,fileInput('hybrid_phenotype',label = h4('hybrid_phe'))),
                                                                          column(width = 4,uiOutput("select_target_cols")),
                                                                          column(width=8,
                                                                                 helpText('A data frame with three columns. The first column and the second column are the names of male and female parents of the corresponding hybrids, respectively; the third column is the phenotypic values of hybrids.')),
                                                                          fluidRow(
                                                                            column(
                                                                              width = 12,
                                                                              h4("Filtered phenotype data preview"),
                                                                              dataTableOutput("hybrid_filtered_phenotype_table")
                                                                            )
                                                                          ))),
                                                        tabPanel(h2('Select methods'),title = 'Methods',
                                                                 fluidRow(column(width=6,selectInput('hpmethod',label=h4('method'),
                                                                                                     choices = list('GBLUP'='GBLUP','BayesB'='BayesB',
                                                                                                                    'RKHS'='RKHS','PLS'='PLS',
                                                                                                                    'LASSO'='LASSO',
                                                                                                                    'XGBoost'='XGBoost'),
                                                                                                     selected = 'GBLUP')))),
                                                        tabPanel(h2('Select hybrids'),title = 'Selection',
                                                                 fluidRow(column(width=6,selectInput('select',label = h4('the selection of hybrids based on the prediction results'),
                                                                                                     choices = list('all potential crosses'='all',
                                                                                                                    'the top n crosses'='top',
                                                                                                                    'the bottom n crosses'='bottom'),selected = 'all'))),
                                                                 fluidRow(column(width=6,numericInput('number',label=h4('the number of selected top or bottom hybrids,only when select = "top" or select = "bottom".'),
                                                                                                      value = 100)))),
                                                        tabPanel(h2('Phenotypic values of the predicted hybrids'),title='Phenotypic values',
                                                                 fluidRow(
                                                                   column(width=6,
                                                                          actionButton('calculate_hybrid', label = h4('Run Hybrid phenotype prediction'), 
                                                                                       style = "background-color: #4CAF50; color: white;"))),
                                                                 fluidRow(column(width = 6,downloadLink('hybrid_predres',label = h4('Download Results')))),
                                                                 fluidRow(column(width=12,DT::dataTableOutput('hybrid_predhyres1'))))),h3("")),
        tabPanel(title = 'phenotype_predict',navlistPanel(widths = c(3,9),
                                                          tabPanel(h2('Predict the Performance of individuals'),title = 'Description',
                                                                   helpText('The phenotype and genotype data of the training population were used to construct models to predict the phenotype of the breeding population.')),
                                                          tabPanel(h2('Input genotype & phenotype'),title = 'Input files',
                                                                   # ===== Modification 1: Train_geno source selection =====
                                                                   fluidRow(
                                                                     column(width=4,
                                                                            radioButtons('train_gen_source', label = h4('Train Genotype Source'),
                                                                                         choices = list('Upload file' = 'upload', 'Use geno_int result' = 'snp'),
                                                                                         selected = 'upload')),
                                                                     column(width=8,
                                                                            helpText('Choose train genotype source: upload your own file, or use matched train_geno from geno_int module.'))
                                                                   ),
                                                                   # Conditional panel: show file upload when upload is selected
                                                                   fluidRow(
                                                                     conditionalPanel(
                                                                       condition = 'input.train_gen_source == "upload"',
                                                                       column(width=4,fileInput('train_gen_upload',label = h4('train_geno'))),
                                                                       column(width=8,helpText( 'genotype data of the training population.'))
                                                                     )
                                                                   ),
                                                                   # Conditional panel: prompt to use matching result when snp is selected
                                                                   fluidRow(
                                                                     conditionalPanel(
                                                                       condition = 'input.train_gen_source == "snp"',
                                                                       column(width=12,
                                                                              helpText(HTML('<span style="color:blue;">Using matched train_geno from geno_int module. Please run geno_int first!</span>')))
                                                                     )
                                                                   ),
                                                                   hr(), # Separator
                                                                   # ===== Modification 2: Breed_geno source selection =====
                                                                   fluidRow(
                                                                     column(width=4,
                                                                            radioButtons('breed_gen_source', label = h4('Breed Genotype Source'),
                                                                                         choices = list('Upload file' = 'upload', 'Use geno_int result' = 'snp'),
                                                                                         selected = 'upload')),
                                                                     column(width=8,
                                                                            helpText('Choose breed genotype source: upload your own file, or use matched breed_geno from geno_int module.'))
                                                                   ),
                                                                   # Conditional panel: show file upload when upload is selected
                                                                   fluidRow(
                                                                     conditionalPanel(
                                                                       condition = 'input.breed_gen_source == "upload"',
                                                                       column(width=4,fileInput('breed_gen_upload',label = h4('breed_geno'))),
                                                                       column(width=8,helpText(' genotype data of the breeding population'))
                                                                     )
                                                                   ),
                                                                   # Conditional panel: prompt to use matching result when snp is selected
                                                                   fluidRow(
                                                                     conditionalPanel(
                                                                       condition = 'input.breed_gen_source == "snp"',
                                                                       column(width=12,
                                                                              helpText(HTML('<span style="color:blue;">Using matched breed_geno from geno_int module. Please run geno_int first!</span>')))
                                                                     )
                                                                   ),
                                                                   hr(), # Separator
                                                                   fluidRow(column(width = 4,fileInput('train_phenotype',label = h4('train_phe'))),
                                                                            column(width = 4,uiOutput("select_target_trait2")),
                                                                            column(width=8,helpText('a vector (n x 1) of phenotype for the training population.')),
                                                                            fluidRow(
                                                                              column(
                                                                                width = 12,
                                                                                h4("Filtered phenotype data preview"),
                                                                                dataTableOutput("train_filtered_phenotype_table")
                                                                              )
                                                                            ))),
                                                          tabPanel(h2('Input design matrix of the fixed effects'),
                                                                   title='Optional Input',
                                                                   fluidRow(
                                                                     column(width=4,
                                                                            radioButtons('trainfixinput', label = h4('design matrix of the  training population fixed effects(Optional)'),
                                                                                         c('Not included'='NULL','Input a design matrix'='input'))),
                                                                     column(width=8,
                                                                            conditionalPanel(condition = 'input.trainfixinput=="input"',
                                                                                             fileInput('train_fix', label=h4('fixed effects'))))),
                                                                   fluidRow(
                                                                     column(width=4,
                                                                            radioButtons('breedfixinput', label = h4('design matrix of the  breed population fixed effects(Optional)'),
                                                                                         c('Not included'='NULL','Input a design matrix'='input'))),
                                                                     column(width=8,
                                                                            conditionalPanel(condition = 'input.breedfixinput=="input"',
                                                                                             fileInput('breed_fix', label=h4('fixed effects')))))),
                                                          tabPanel(h2('Select methods'),title = 'Methods',
                                                                   fluidRow(column(width=6,selectInput('method',label=h4('method'),
                                                                                                       choices = list('GBLUP'='GBLUP','BayesB'='BayesB',
                                                                                                                      'RKHS'='RKHS','PLS'='PLS',
                                                                                                                      'LASSO'='LASSO',
                                                                                                                      'XGBoost'='XGBoost'),
                                                                                                       selected = 'GBLUP')))),
                                                          tabPanel(h2('Phenotypic values of the predicted individuals'),title='Phenotypic values',
                                                                   fluidRow(
                                                                     column(width=6,
                                                                            actionButton('calculate_p', label = h4('Run Phenotype Prediction'), 
                                                                                         style = "background-color: #4CAF50; color: white;"))),
                                                                   fluidRow(column(width = 6,downloadLink('phenotype_predhyres',label = h4('Download Results')))),
                                                                   fluidRow(column(width=12,DT::dataTableOutput('phenotype_predhyres1'))))),h3(""))))
    
    ###################################server#######################################
    server <- function(input, output, session) {
      options(shiny.maxRequestSize=10*1024^3) # Max upload size = 10G
      
      ####################################cv##########################################
      cv_fix <- reactive({
        req(input$fix)
        as.matrix(fread(input$fix$datapath, header = TRUE, stringsAsFactors = FALSE))
      })
      
      cv_genotype <- reactive({
        if (input$geno_source == "upload") {
          req(input$inbred_gen_upload)
          df <- as.data.frame(
            fread(
              input$inbred_gen_upload$datapath,
              header = TRUE,
              stringsAsFactors = FALSE
            )
          )
          row.names(df) <- df[, 1]
          as.matrix(df[, -1, drop = FALSE])
        } else {
          req(gena())
          gena()
        }
      })
      
      cv_phenotype1 <- reactive({
        req(input$cv_phenotype)  # Ensure phenotype file is uploaded
        pheno_df <- as.data.frame(
          fread(
            input$cv_phenotype$datapath,  # Temporary path of uploaded file
            header = TRUE,             # Keep header
            stringsAsFactors = FALSE   # Do not convert character to factor
          )
        )
      })
      # 2. Dynamically render multi-column selection box (core: multiple=TRUE to enable multi-selection)
      output$select_target_trait1<- renderUI({
        df <- cv_phenotype1()  # Get uploaded data frame
        col_names <- colnames(df)  # Extract all column names
        
        # Render multi-select dropdown: multiple=TRUE allows selecting 1 or more columns
        selectInput(
          inputId = "target_trait1",  # Input ID for getting selection result later
          label = h4(""),
          choices = col_names,  # Dynamically load column names of uploaded data
          selected = NULL,  # Default select first column (optional: change to NULL for no default selection)
          multiple = TRUE  # Key parameter: enable multi-selection for variable column selection
        )
      })
      # 3. Filter variable number of target columns (return 1 column if user selects 1, return multiple if user selects multiple)
      cv_filtered_phenotype <- reactive({
        req(cv_phenotype1(),input$target_trait1)  # Wait for user to select target columns
        df <- cv_phenotype1()
        # Filter selected columns (input$target_cols is character vector corresponding to selected column names)
        target_trait1 <- input$target_trait1
        filtered_df <- df[, target_trait1]  # drop=FALSE ensures returning data frame even if 1 column is selected
        return(filtered_df)
      })
      
      output$cv_filtered_phenotype_table <- renderDataTable({
        vec_data <- cv_filtered_phenotype()
        df_data <- data.frame(Trait = vec_data)
        return(df_data)
      })
      
      cv_method <- reactive({
        switch(input$cvmethod,
               'GBLUP'='GBLUP','BayesB'='BayesB',
               'RKHS'='RKHS','PLS'='PLS',
               'LASSO'='LASSO',
               'XGBoost'='XGBoost',
               'ALL'='ALL')
      })
      
      cvres <- reactiveVal(NULL)
      
      observeEvent(input$calculate_cv, {
        
        req(cv_genotype(),cv_filtered_phenotype())
        result<-if(input$cvfixinput == 'input'){
          cv(
            fix = cv_fix(),
            gen = cv_genotype(),
            y =  cv_filtered_phenotype(),
            method = cv_method(),
            nfold = input$nfold,
            nTimes = input$ntimes,
            seed = input$cvseed,
            CPU = input$CPU,
            drawplot = FALSE
          )
        } else {
          cv(
            fix = NULL,
            gen = cv_genotype(),
            y =  cv_filtered_phenotype(),
            method = cv_method(),
            nfold = input$nfold,
            nTimes = input$ntimes,
            seed = input$cvseed,
            CPU = input$CPU,
            drawplot = FALSE
          )
        }
        cvres(result)
      })
      output$cvres1 <- DT::renderDataTable({
        req(cvres())
        DT::datatable(cvres(), options = list(pageLength = 10))
      })
      
      output$cvres2 <- downloadHandler(
        filename = function(){
          paste("cv-","results-", cv_method(), '-', Sys.Date(), '.csv', sep = "")
        },
        content = function(file) {
          write.csv(cbind(rownames(cvres()), cvres()), file, row.names = FALSE)
        }
      )
      # #####################################hybrid_predict#############################
      inbred_geno <- reactive({
        if (input$inbred_gen_source == "upload") {
          req(
            input$inbred_gen_upload
          )
          df <- as.data.frame(
            fread(
              input$inbred_gen_upload$datapath,
              header = TRUE,
              stringsAsFactors = FALSE
            )
          )
          row.names(df) <- df[, 1]
          as.matrix(df[, -1, drop = FALSE])
        } else {
          req(convertgen())
          convertgen()
        }
      })
      
      hybrid_phenotype1 <- reactive({
        req(input$hybrid_phenotype)  # Ensure phenotype file is uploaded
        pheno_df <- as.data.frame(
          fread(
            input$hybrid_phenotype$datapath,  # Temporary path of uploaded file
            header = TRUE,             # Keep header
            stringsAsFactors = FALSE   # Do not convert character to factor
          )
        )
      })
      # 2. Dynamically render multi-column selection box (core: multiple=TRUE to enable multi-selection)
      output$select_target_cols<- renderUI({
        df <-  hybrid_phenotype1()  # Get uploaded data frame
        col_names <- colnames(df)  # Extract all column names
        
        # Render multi-select dropdown: multiple=TRUE allows selecting 1 or more columns
        selectInput(
          inputId = "target_cols",  # Input ID for getting selection result later
          label = h4(""),
          choices = col_names,  # Dynamically load column names of uploaded data
          selected = col_names[1:3],  # Default select first column (optional: change to NULL for no default selection)
          multiple = TRUE  # Key parameter: enable multi-selection for variable column selection
        )
      })
      # 3. Filter variable number of target columns (return 1 column if user selects 1, return multiple if user selects multiple)
      hybrid_filtered_phenotype <- reactive({
        req( hybrid_phenotype1(),input$target_cols)  # Wait for user to select target columns
        df <-  hybrid_phenotype1()
        # Filter selected columns (input$target_cols is character vector corresponding to selected column names)
        target_cols <- input$target_cols
        filtered_df <- df[, target_cols, drop = FALSE]  # drop=FALSE ensures returning data frame even if 1 column is selected
        return(filtered_df)
      })
      
      output$hybrid_filtered_phenotype_table <- renderDataTable({
        hybrid_filtered_phenotype()
      })
      hybrid_predict_method <- reactive({switch(input$hpmethod,
                                                'GBLUP'='GBLUP','BayesB'='BayesB',
                                                'RKHS'='RKHS','PLS'='PLS',
                                                'LASSO'='LASSO',
                                                'XGBoost'='XGBoost')
      })
      
      select <- reactive({switch(input$select,
                                 'all'='all',
                                 'top'='top',
                                 'bottom'='bottom')
      })
      number <- reactive({ifelse(select()=='all',NULL,input$number)})
      
      pred <- reactiveVal(NULL)
      
      observeEvent(input$calculate_hybrid, {
        
        req(inbred_geno(),hybrid_filtered_phenotype())
        
        result<-hybrid_predict(inbred_gen = inbred_geno(),hybrid_phe=hybrid_filtered_phenotype(),method=hybrid_predict_method(),select(),number())
        pred(result)
      })
      
      output$hybrid_predhyres1 <- DT::renderDataTable({
        req(pred())
        DT::datatable(pred(), options = list(pageLength = 10, scrollX = TRUE))
      })
      output$hybrid_predres <- downloadHandler(
        filename = function(){
          paste("hp-","results",'-',hybrid_predict_method(),Sys.Date(),'.csv', sep = "")
        },
        content = function(file) {
          write.csv(cbind(rownames(pred()),pred()), file, row.names = FALSE)
        })
      
      #####################################phenotype_predict#############################
      
      phenotype_train_gen <- reactive({
        if (input$train_gen_source == "upload") {
          req(input$train_gen_upload)
          df <-as.data.frame(fread(input$train_gen_upload$datapath,header = T,stringsAsFactors=F))
          row.names(df) <- df[,1]
          df <- as.matrix(df[,-1])
        } else {
          req(match_train_geno())
          match_train_geno()
        }
      })
      
      phenotype_breed_gen <- reactive({
        if (input$breed_gen_source == "upload") {
          req(input$breed_gen_upload)
          df <-as.data.frame(fread(input$breed_gen_upload$datapath,header = T,stringsAsFactors=F))
          row.names(df) <- df[,1]
          df <- as.matrix(df[,-1])
        } else {
          req(match_breed_geno())
          match_breed_geno()
        }
      })
      
      train_phenotype1 <- reactive({
        req(input$train_phenotype)  # Ensure phenotype file is uploaded
        pheno_df <- as.data.frame(
          fread(
            input$train_phenotype$datapath,  # Temporary path of uploaded file
            header = TRUE,             # Keep header
            stringsAsFactors = FALSE   # Do not convert character to factor
          )
        )
      })
      # 2. Dynamically render multi-column selection box (core: multiple=TRUE to enable multi-selection)
      output$select_target_trait2<- renderUI({
        df <-  train_phenotype1()  # Get uploaded data frame
        col_names <- colnames(df)  # Extract all column names
        
        # Render multi-select dropdown: multiple=TRUE allows selecting 1 or more columns
        selectInput(
          inputId = "target_trait2",  # Input ID for getting selection result later
          label = h4(""),
          choices = col_names,  # Dynamically load column names of uploaded data
          selected = NULL,  # Default select first column (optional: change to NULL for no default selection)
          multiple = TRUE  # Key parameter: enable multi-selection for variable column selection
        )
      })
      # 3. Filter variable number of target columns (return 1 column if user selects 1, return multiple if user selects multiple)
      train_filtered_phenotype <- reactive({
        req(train_phenotype1(),input$target_trait2)  # Wait for user to select target columns
        df <-  train_phenotype1 ()
        # Filter selected columns (input$target_cols is character vector corresponding to selected column names)
        target_trait2 <- input$target_trait2
        filtered_df <- df[, target_trait2]  # drop=FALSE ensures returning data frame even if 1 column is selected
        return(filtered_df)
      })
      
      output$train_filtered_phenotype_table <- renderDataTable({
        vec_data <- train_filtered_phenotype()
        df_data <- data.frame(Trait = vec_data)
        return(df_data)
      })
      
      train_fix <- reactive({
        req(input$train_fix)
        df<-as.matrix(fread(input$train_fix$datapath, header = TRUE, stringsAsFactors = FALSE))
      })
      breed_fix <- reactive({
        req(input$breed_fix)
        df<-as.matrix(fread(input$breed_fix$datapath, header = TRUE, stringsAsFactors = FALSE))
      })
      
      phenotype_method <- reactive({switch(input$method,
                                           'GBLUP'='GBLUP','BayesB'='BayesB',
                                           'RKHS'='RKHS','PLS'='PLS',
                                           'LASSO'='LASSO',
                                           'XGBoost'='XGBoost')
      })
      
      phenotype_pred <- reactiveVal(NULL)
      
      observeEvent(input$calculate_p, {
        # cat("===== Final parameters passed to phenotype_predict =====\n")
        # cat("Is train_geno NULL：", is.null(phenotype_train_gen()), "\n")
        # cat("train_geno dimensions：", dim(phenotype_train_gen()), "\n")
        # cat("Is breed_geno NULL：", is.null(phenotype_breed_gen()), "\n")
        # cat("Is train_phe NULL：", is.null(train_filtered_phenotype()), "\n")
        
        result <- if(input$trainfixinput=='input'&input$breedfixinput=='input'){
          
          phenotype_predict(train_fix(), breed_fix(), train_geno=phenotype_train_gen(), breed_geno=phenotype_breed_gen(), train_phe=train_filtered_phenotype(), method=phenotype_method())
        }else{
          phenotype_predict(train_fix = NULL, breed_fix = NULL,train_geno=phenotype_train_gen(), breed_geno=phenotype_breed_gen(), train_phe=train_filtered_phenotype(), method=phenotype_method())
        }
        phenotype_pred(result)
      })
      
      output$phenotype_predhyres1 <- DT::renderDataTable({
        phenotype_pred()
      })
      
      output$phenotype_predhyres <- downloadHandler(
        filename = function(){
          paste('results','-',phenotype_method(),Sys.Date(),'.csv', sep = "")
        },
        content = function(file) {
          write.csv(cbind(rownames(phenotype_pred()),phenotype_pred()), file, row.names = FALSE)
        })
      
      #################################convert#####################################
      filetype <- reactive({
        switch(input$geno_type,
               'hmp1'='hmp1',
               'hmp2'='hmp2',
               'vcf'='vcf',
               'num'='num')
      })
      
      rawgene <- reactive({
        # Ensure user has entered path in text box (input$geno is string)
        req(input$geno_path)
        
        # Get manually entered path (string format)
        file_path <- input$geno_path$datapath
        cat(file_path)
        
        return(file_path)
      })
      
      convertgen<- reactiveVal(NULL)
      observeEvent(input$calculate_num, {
        cat("===== Button calculate_num clicked, starting conversion logic =====\n")
        req(rawgene())
        result<-convert(
          rawgene(),
          type = filetype(),
          missingrate = input$missingrate,
          maf = input$maf,
          impute = input$impute,
          dir = input$dir_path
        )
        convertgen(result)
      })
      
      output$convered <- downloadHandler(
        filename = function() {
          paste('convert_results-', Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          write.csv(convertgen(), file, row.names = TRUE)
        }
      )
      
      output$convertview <- DT::renderDataTable({
        req(convertgen())
        DT::datatable(convertgen(), options = list(pageLength = 10))
      })
      #
      # #################################infergen#####################################
      infergen_inbred_gen <- reactive({
        if (input$inbred_gen_source == "upload") {
          req(input$inbred_gen_upload)
          df <- as.data.frame(fread(input$inbred_gen_upload$datapath, header = TRUE, stringsAsFactors = FALSE))
          row.names(df) <- df[, 1]
          as.matrix(df[, -1, drop = FALSE]) # Upload file path
        } else {
          req(convertgen())  # Dependent on convert module result
          convertgen()
        }
      })
      
      crosses1 <- reactive({
        req(input$crosses)  # Ensure phenotype file is uploaded
        pheno_df <- as.data.frame(
          fread(
            input$crosses$datapath,  # Temporary path of uploaded file
            header = TRUE,             # Keep header
            stringsAsFactors = FALSE   # Do not convert character to factor
          )
        )
      })
      infered<- reactiveVal(NULL)
      observeEvent(input$calculate_infered, {
        req(infergen_inbred_gen(),crosses1())  # Ensure both inputs have values
        
        result<-infergen(
          inbred_gen = as.matrix(infergen_inbred_gen()),
          hybrid_phe = crosses1()
          
        )
        infered(result)
      })
      
      gena <- reactive({
        infered()$add
      })
      output$inferened <- downloadHandler(
        filename = function() {
          paste('inferened_results-', Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          write.csv(gena(), file, row.names = TRUE)
        }
      )
      
      output$infergenview <- DT::renderDataTable({
        req(gena())
        DT::datatable(gena(), options = list(pageLength = 10))
      })
      #
      # # #################################snp_match#####################################
      #
      train_rawgene <- reactive({
        # Ensure user has entered path in text box (input$geno is string)
        req(input$train_geno_path)
        
        # Get manually entered path (string format)
        file_path <- input$train_geno_path$datapath
        
        return(file_path)
      })
      breed_rawgene <- reactive({
        # Ensure user has entered path in text box (input$geno is string)
        req(input$breed_geno_path)
        
        # Get manually entered path (string format)
        file_path <- input$breed_geno_path$datapath
        cat(file_path)
        
        return(file_path)
      })
      
      #
      train_crosses <- reactive({
        req(input$train_crosses)
        df<-as.matrix(fread(input$train_crosses$datapath, header = TRUE, stringsAsFactors = FALSE))
      })
      breed_crosses <- reactive({
        req(input$breed_crosses)
        df<-as.matrix(fread(input$breed_crosses$datapath, header = TRUE, stringsAsFactors = FALSE))
      })
      
      
      snpmatchres<- reactiveVal(NULL)
      observeEvent(input$calculate_match, {
        
        req(train_rawgene())
        req(breed_rawgene())
        result<-if(input$traincrossinput == 'input'&input$breedcrossinput == 'input'){
          geno_int(
            train_rawgene(),
            breed_rawgene(),
            type = filetype(),
            missingrate = input$missingrate,
            maf = input$maf,
            impute = input$impute,
            dir = input$dir_path,
            train_crosses=train_crosses(),
            breed_crosses=breed_crosses()
          )}
        else  {
          geno_int(
            train_rawgene(),
            breed_rawgene(),
            type = filetype(),
            missingrate = input$missingrate,
            maf = input$maf,
            impute = input$impute,
            dir = input$dir_path,
            train_crosses=NULL,
            breed_crosses=NULL
            
          )}
        snpmatchres(result)
      })
      match_train_geno <- reactive({
        snpmatchres()$train_geno
      })
      
      match_breed_geno <- reactive({
        snpmatchres()$breed_geno
      })
      
      # ========== 1. Download for training genotype (train_geno) ==========
      output$download_train_geno <- downloadHandler(
        filename = function() {
          # Distinguish filenames between train and breed to avoid overwriting
          paste('train_geno_matched-', Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          req(match_train_geno())  # Ensure train_geno has result
          # Unify conversion to data frame (compatible with matrix/data frame format)
          train_geno_df <- as.data.frame(match_train_geno())
          write.csv(train_geno_df, file, row.names = TRUE)
        }
      )
      #
      # ========== 2. Download for breeding genotype (breed_geno) ==========
      output$download_breed_geno <- downloadHandler(
        filename = function() {
          paste('breed_geno_matched-', Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          req(match_breed_geno())  # Ensure breed_geno has result
          breed_geno_df <- as.data.frame(match_breed_geno())
          write.csv(breed_geno_df, file, row.names = TRUE)
        }
      )
      
      # # ========== 3. Table display for training genotype ==========
      output$match_train_geno_view <- DT::renderDataTable({
        req(match_train_geno())
        DT::datatable(
          as.data.frame(match_train_geno()),  # Convert to data frame for DT display
          options = list(
            pageLength = 10,
            scrollX = TRUE  # Horizontal scroll for wide genotype tables
          ),
          rownames = TRUE,  # Show row names (locus/sample names)
          caption = "Matched Training Genotype"
        )
      })
      
      # # ========== 4. Table display for breeding genotype ==========
      output$match_breed_geno_view <- DT::renderDataTable({
        req(match_breed_geno())
        DT::datatable(
          as.data.frame(match_breed_geno()),
          options = list(
            pageLength = 10,
            scrollX = TRUE
          ),
          rownames = TRUE,
          caption = "Matched Breeding Genotype"
        )
      })
      
      output$convered <- downloadHandler(
        filename = function() {
          paste('convert_results-', Sys.Date(), ".csv", sep = "")
        },
        content = function(file) {
          write.csv(convertgen(), file, row.names = TRUE)
        }
      )
      #
      output$convertview <- DT::renderDataTable({
        req(convertgen())
        DT::datatable(convertgen(), options = list(pageLength = 10))
      })
      
      
      ###############################
      # Function 1: Genotype data conversion jump
      observeEvent(input$link_geno_conversion, {
        updateNavbarPage(session, "main_navbar", selected = "convert")
      })
      
      # Function 2: Hybrid genotype infergen jump
      observeEvent(input$link_hybrid_geno, {
        updateNavbarPage(session, "main_navbar", selected = "infergen")
      })
      
      # Function 3: snp match jump
      observeEvent(input$link_geno_int, {
        updateNavbarPage(session, "main_navbar", selected = "geno_int")
      })
      
      # Function 4: Evaluation of predictability jump
      observeEvent(input$link_predict_eval, {
        updateNavbarPage(session, "main_navbar", selected = "cv")
      })
      
      # Function 5: Prediction of hybrid phenotype jump
      observeEvent(input$link_hybrid_phe, {
        updateNavbarPage(session, "main_navbar", selected = "hybrid_predict")
      })
      
      # Function 6: Prediction of phenotype jump
      observeEvent(input$link_pheno_pred, {
        updateNavbarPage(session, "main_navbar", selected = "phenotype_predict")
      })
      
    }
    
    shinyApp(ui = ui, server = server)
  }
}
