##### Project Info #####
# Name: Name Game dashboard
# Description: Shiny dashboard to facilitate remote play of Name Game
# Author: Michal Przydacz

##### Project Setup #####

# Load libraries and functions
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

source("Googledocs_auxiliary_functions.R")

##### Shiny Ui #####

ui <- dashboardPage(
  dashboardHeader(title = "Name Game Dashboard",
                  titleWidth = "300px"),
  dashboardSidebar(
    sidebarMenu(id = "tabs",
      menuItem("Game setup", tabName = "tab_teams"),
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
                         fluidRow(
                           column(width = 8, 
                                  sliderInput("teams_slider", "Number of teams",
                                              min = 1, max = 4, value = 2)),
                           column(width = 4,  
                                  actionButton("teams_button", "Form teams"))
                         )
                  ),
                  column(width = 4,
                         DTOutput("teams_dt")
                  )
                )
              )
      ),
      tabItem(tabName = "tab_game",
              fluidPage(
                fluidRow(
                  column(width = 4),
                  column(width = 4),
                  column(width = 4)
                )
              )
      )
    )
  )
)


##### Shiny Server #####

server <- function(input, output, session) {
  
  rv <- reactiveValues()
  
  ## Tab: Game setup -----------------------------------------------------------
  
  # Import Players
  players <- reactive({
    tmp_path <- fs::file_temp(ext = "csv")
    drive_download("Name_Game/players", path = tmp_path)
    players <- read_csv(tmp_path, col_types = "c")
    fs::file_delete(tmp_path)
    players
  })
  
  # Display players
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

    no_teams <- input$teams_slider
    groupings <- str_glue("Team {seq(1:no_teams)}")

    if(nrow(players_df)==no_teams){
      teams <- groupings
    }else if(nrow(players_df)%%no_teams==0) {
      teams <- rep(groupings, no_teams)
    } else {
      teams <- rep(groupings, floor(nrow(players_df)/no_teams))
      extra <- groupings[1:floor(nrow(players_df)%%no_teams)]
      teams <- append(teams, extra)
    }

    players_teams <- players_df %>%
      slice_sample(prop = 1) %>%
      mutate(Team = teams) %>%
      arrange(Team)
  })
  
  # Display teams
  output$teams_dt <- renderDT({
    datatable(player_groups(),
              selection = "none",
              options = list(
                dom = "t"
              )
    )
  })
  
  ## Tab: Game -----------------------------------------------------------------
  
  # Import words collection
  tmp_path <- fs::file_temp(ext = "csv")
  drive_download("Name_Game/names", path = tmp_path)
  rv$names <- read_csv(tmp_path, col_types = "c")
  fs::file_delete(tmp_path)
  
}

shiny::shinyApp(ui, server)
