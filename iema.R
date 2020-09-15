# install.packages(c("modelStudio", "gbm", "DALEX"))
library(DALEX)
data <- fifa
data$wage_eur <- data$overall <- data$potential <- data$nationality <- NULL
data$value_eur <- log10(data$value_eur)
set.seed(1313)
library(gbm)
model <- gbm(value_eur ~ . , data = data, n.trees = 300, interaction.depth = 4)
explainer <- DALEX::explain(model, 
                            data = data[,-1], 
                            y = 10^data$value_eur, 
                            predict_function = function(m,x) 
                              10^predict(m, x, n.trees = 300),
                            label = 'gbm')

library(modelStudio)

# Use parallelMap to speed up the computation
options(
  parallelMap.default.mode        = "socket",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = FALSE
)

# Pick observations
fifa_selected <- data[1:40, ]

# Make a studio for the model
iema_ms <- modelStudio(
  explainer, 
  new_observation = fifa_selected,
  B = 20,
  parallel = TRUE,
  rounding_function = signif, digits = 5,
  options = ms_options(
    #show_boxplot = FALSE,
    margin_left = 160,
    margin_ytitle = 100,
    ms_title = "Interactive Studio for GBM model on FIFA 20 data"
  )
)

iema_ms

# Save as HTML
r2d3::save_d3_html(iema_ms, file = "iema.html")
