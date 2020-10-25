##### Project Info #####
# Name: Name Game dashboard
# Description: Shiny dashboard to facilitate remote play of Name Game
# Author: Michal Przydacz

##### Project Setup #####

# Load libraries
library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(googledrive)
library(tidylog)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(DT)
library(rtweet)

##### Shiny Ui #####

ui <- dashboardPage(
  dashboardHeader(title = "Name Game Dashboard",
                  titleWidth = "300px"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Game setup", tabName = "tab_teams",
               sliderInput("teams_slider", "Number of teams",
                           min = 1, max = 4, value = 2)),
      menuItem("Game", tabName = "tab_game")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "tab_teams",
              fluidPage(
                fluidRow(
                  column(width = 4, 
                         DTOutput("players_dt"),
                         actionButton("teams_button", "From teams"))
                )
              )
      ),
      tabItem(tabName = "tab_game")
    )
  )
)


##### Shiny Server #####

server <- function(input, output, session) {
  
  ## Tab: Game setup -----------------------------------------------------------
  
  # Import Players
  players <- reactive({
    tmp_path <- fs::file_temp(ext = "csv")
    drive_download("Name_Game/players", path = tmp_path)
    players <- read_csv(tmp_path, col_types = "c")
    fs::file_delete(tmp_path)
    players
  })
  
  output$players_dt <- renderDT({
    
    datatable(players(),
              selection = "none",
              options = list(
                dom = "t"
              )
    )
  })
  
  # Create random groups
  player_groups <- eventReactive(input$teams_button, {
    players_df <- players()
    
  })
  
}

shiny::shinyApp(ui, server)
