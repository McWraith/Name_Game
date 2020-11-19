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
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(DT)
library(rtweet)
library(tidylog)

options(gargle_oauth_cache = ".secrets")
drive_auth(cache = ".secrets", email = TRUE)

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
                  column(
                    width = 12,
                    box(htmlOutput("cur_round"))
                  )
                ),
                fluidRow(
                  column(width = 4,
                         box(title = "Current Team",
                             width = 6,
                             solidHeader = TRUE,
                             htmlOutput("cur_team")),
                         box(title = "Current Player",
                             width = 6,
                             solidHeader = TRUE,
                             htmlOutput("cur_player"))
                  ),
                  column(width = 4,
                         box(title = "Names left in the hat",
                             width = 6,
                             solidHeader = TRUE,
                             htmlOutput("hat")),
                         box(title = "Timer",
                             width = 6,
                             solidHeader = TRUE,
                             htmlOutput("timerUI"))
                  ),
                  column(width = 4,
                         box(title = "Current Scores",
                             width = 12,
                             solidHeader = TRUE,
                             DTOutput("team_score_dt"))
                  )
                ),
                fluidRow(
                  column(
                    width = 3,
                    actionButton("game_start", label = "Start")
                  ),
                  column(
                    width = 3,
                    actionButton("score_plus", label = "Correct")
                  ),
                  column(
                    width = 3,
                    actionButton("score_pass", label = "PASS")
                  )
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
    gd_download("Name_Game/players")
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
    group_test <<- player_groups()
    datatable(player_groups(),
              selection = "none",
              options = list(
                dom = "t"
              )
    )
  })
  
  ## Tab: Game -----------------------------------------------------------------

  # Hat ----
  # Import words collection
  rv$names <- gd_download("Name_Game/names")

  hat_n <- reactiveVal(nrow(isolate(rv$names))+1)
  
  hat <- eventReactive(input$score_plus, {
    hat_n(hat_n()-1)
    hat_n()
  }, ignoreNULL = FALSE)
  
  output$hat <- renderUI({
    HTML(paste(hat()))
  })
  
  # Timer ----
  timer <- reactiveVal(0)
  timer_active <- reactiveVal(FALSE)
  
  observeEvent(
    input$game_start, {
    timer(10)
    timer_active(TRUE)
  })
  
  observe({
    invalidateLater(1000, session)
    isolate({
      if(timer_active()){
        if(timer() > 0){
          timer(timer() - 1)
        } else {
          timer_active(FALSE)
          showModal(
            modalDialog("Time's Up!")
          )
        }
      }
    })
  })
  
  output$timerUI <- renderUI({
    HTML(paste(timer()))
  })
  
  
}

shiny::shinyApp(ui, server)
