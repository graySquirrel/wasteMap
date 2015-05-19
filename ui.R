library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)


shinyUI(navbarPage("Superzip", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      # cut and paste the below line into browser works Ok.
      #https://a.tiles.mapbox.com/v4/ebner.m6hab7b1/page.html?access_token=pk.eyJ1IjoiZWJuZXIiLCJhIjoiM2tCcWozSSJ9.EnkNFRKUEmpSDa1eskNepw#6/43.061/-78.223
      leafletMap("map", width="100%", height="100%",
        #initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",  
        initialTileLayer = 
            "//a.tiles.mapbox.com/v3/ebner.map-m6hab7b1/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiZWJuZXIiLCJhIjoiM2tCcWozSSJ9.EnkNFRKUEmpSDa1eskNepw",
        #initialTileLayer = "//{s}.tiles.mapbox.com/v3/ebner.m6hab7b1?access_token=pk.eyJ1IjoiZWJuZXIiLCJhIjoiM2tCcWozSSJ9.EnkNFRKUEmpSDa1eskNepw#6/{z}/{x}/{y}.png",
        #initialTileLayer = "//{s}.tiles.mapbox.com/v3/ebner.m6hab7b1/{z}/{x}/{y}.png",
        #initialTileLayer = "//a.tiles.mapbox.com/v4/ebner.m6hab7b1/page.html?access_token=pk.eyJ1IjoiZWJuZXIiLCJhIjoiM2tCcWozSSJ9.EnkNFRKUEmpSDa1eskNepw#6/43.061/-78.223",
        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
        
        # below works.
        #initialTileLayer = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
        #initialTileLayerAttribution = HTML('© OpenStreetMap contributors, CC-BY-SA'),
        options=list(
          center = c(37.45, -93.85),
          zoom = 4,
          maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481)) # Show US only
        )
      ),

      # Shiny versions prior to 0.11 should use class="modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",

        h2("ZIP explorer"),

        selectInput("color", "Color", vars),
        selectInput("size", "Size", vars, selected = "adultpop"),
        conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
          # Only prompt for threshold when coloring or sizing by superzip
          numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
        ),

        plotOutput("histCentile", height = 200),
        plotOutput("scatterCollegeIncome", height = 250)
      ),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960â€“2010'), ' by Charles Murray (Crown Forum, 2012).'
      )
    )
  ),

  tabPanel("Data explorer",
    fluidRow(
      column(3,
        selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
      ),
      column(3,
        conditionalPanel("input.states",
          selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
        )
      ),
      column(3,
        conditionalPanel("input.states",
          selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
        )
      )
    ),
    fluidRow(
      column(1,
        numericInput("minScore", "Min score", min=0, max=100, value=0)
      ),
      column(1,
        numericInput("maxScore", "Max score", min=0, max=100, value=100)
      )
    ),
    hr(),
    dataTableOutput("ziptable")
  ),

  conditionalPanel("false", icon("crosshair"))
))
