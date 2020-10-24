##### Project Info #####
# Name: Name Game dashboard
# Description: Shiny dashboard to facilitate remote play of Name Game
# Author: Michal Przydacz

##### Project Setup #####
# Load libraries
library(tidyverse)
library(googledrive)
library(tidylog)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(rtweet)

##### Shiny Ui #####

ui <- dashboardPage(
  dashboardHeader(title = "Name Game Dashboard",
                  titleWidth = "300px"),
  dashboardSidebar(),
  dashboardBody()
)


##### Shiny Server #####

server <- function(input, output, session) {
  ##### Twitter API setup
  source("secret")
  
  token <- rtweet::create_token(app = app, 
                                consumer_key = consumer_key, 
                                consumer_secret = consumer_secret,
                                access_token = access_token,
                                access_secret = access_secret,
                                set_renv = FALSE) # Needs to be set to TRUE on first run
  
  
}

shiny::shinyApp(ui, server)
