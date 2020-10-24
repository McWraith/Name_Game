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

##### Shiny Ui

ui <- dashboardPage()


##### Shiny Server

server <- function(input, output, session) {
  
}

shiny::shinyApp(ui, server)
