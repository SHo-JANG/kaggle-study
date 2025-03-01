#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(tidymodels)
library(tidyverse)
library(palmerpenguins)
library(xgboost)


model <- readRDS("penguin_model.rds")

# model$pre$mold$predictors %>% colnames()
# summary(penguins)

# predict(
#   model, 
#   tibble("island" = "Biscoe",
#          "bill_length_mm" = 30,
#          "bill_depth_mm" = 10,
#          "flipper_length_mm" = 170,
#          "body_mass_g" = 3200,
#          "sex" = "Male",
#          "year" = 2007),
#   type = "prob"
# ) %>% gather() %>% arrange(desc(value)) %>% .[1,] %>% select(value)

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    menuItem(
      "Penguin Species",
      tabName = "penguin_tab",
      icon = icon("snowflake")
    )
  ),
  dashboardBody(
    tabItem(
      tabName = "penguin_tab",
      box(valueBoxOutput("penguin_prediction")),
      box(selectInput("v_island", label = "Island",
                      choices = c("Biscoe", "Dream", "Torgersen"))),
      box(selectInput("v_sex", label = "Sex",
                      choices = c("Female", "Male"))),
      box(sliderInput("v_bill_length", label = "Bill Length (mm)",
          min = 30, max = 60, value = 45)),
      box(sliderInput("v_bill_depth", label = "Bill Depth (mm)",
        min = 10, max = 25, value = 17)),
      box(sliderInput("v_flipper_length", label = "Flipper Length (mm)",
        min = 170, max = 235, value = 200)),
      box(sliderInput("v_body_mass", label = "Body Mass (g)",
        min = 2700, max = 6300, value = 4000)),
      box(sliderInput("v_year", label = "Year",
        min = 2007, max = 2009, value = 2008))
    )
  )
)

server <- function(input, output) {
  
  output$penguin_prediction <- renderValueBox({
    prediction <- predict(
      model, 
      tibble("island" = input$v_island,
             "bill_length_mm" = input$v_bill_length,
             "bill_depth_mm" = input$v_bill_depth,
             "flipper_length_mm" = input$v_flipper_length,
             "body_mass_g" = input$v_body_mass,
             "sex" = input$v_sex,
             "year" = input$v_year)
    )
    
    prediction_prob <- predict(
      model, 
      tibble("island" = input$v_island,
             "bill_length_mm" = input$v_bill_length,
             "bill_depth_mm" = input$v_bill_depth,
             "flipper_length_mm" = input$v_flipper_length,
             "body_mass_g" = input$v_body_mass,
             "sex" = input$v_sex,
             "year" = input$v_year),
      type = "prob"
    ) %>% gather() %>%
      arrange(desc(value)) %>%
      .[1,] %>%
      select(value)
    
    prediction_color <- if_else(prediction$.pred_class == "Adelie", "blue",
                                if_else(prediction$.pred_class == "Gentoo", "red", "yellow"))
    
    valueBox(
      value = paste0(round(100*prediction_prob$value, 0), "%"),
      subtitle = paste0("Species: ", prediction$.pred_class),
      color = prediction_color,
      icon = icon("snowflake")
    )
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

