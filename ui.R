library(RColorBrewer)
library(shiny)
library(leaflet)
data <- read.csv("AusStage_S12025PE2v2.csv")
shinyUI(
  fixedPage(
    titlePanel("Mapping Victoria's Performing Arts Events"),
    
    # MAP section
    # Year range slider to filter events shown on the map
    sliderInput("yearRange",
                "Select First to Last Year Range:",
                min = min(data$First.Year, na.rm = TRUE),
                max = max(data$Last.Year, na.rm = TRUE),
                value = c(min(data$First.Year, na.rm = TRUE), max(data$Last.Year, na.rm = TRUE)),
                step = 1,
                sep = ""
    ),
    # Leaflet output for the interactive map
    leafletOutput("mapPlot", height = "600px"),
    
    # Map description
    p("This interactive map visualises venues across Victoria, with each circle representing a venue-genre combination. The radius of each circle encodes the number of events hosted, while colour represents the Primary Genre. The user can explore event patterns by using the year range slider to filter performances by time period. Hovering over a circle reveals a tooltip with the venue name, suburb, genre, and event count, offering contextual details on demand. The map shows a dense cluster of events in Melbourne, especially in suburbs like Carlton. Theatre - Spoken Word is widely distributed, while Music and Dance appear more concentrated in fewer venues."),
    
    # VIS1
    # Layout: two columns side-by-side
    fluidRow(
      column(6,
             # Static bar chart of top 10 venues
             plotOutput("vis1Plot", height = "400px")
      ),
      column(6,
             # Description and interpretation of the bar chart
             p("This static bar chart displays the top 10 most frequently used venues for performing arts events in Victoria, based on the number of unique events. Each bar represents a venue, and the bar length indicates the total event count, allowing users to quickly compare venue popularity. The coloured segments within each bar represent the Primary Genre breakdown, providing a deeper insight into the types of performances most associated with each venue. Ordering the bars from highest to lowest ensures clarity in ranking. The chart reveals, for instance, that La Mama is the most frequently used venue, heavily dominated by Theatre - Spoken Word.")
      )
    ),
    
    # Data source citation (source, link, licensor, and date)
    p(
      "Data Source: AusStage Database | ",
      a("https://www.ausstage.edu.au/pages/learn/search-ausstage", 
        href = "https://www.ausstage.edu.au/pages/learn/search-ausstage", target = "_blank"),
      " | Licensor: AusStage Consortium | Data Version: 28 February 2025"
    )
    
    )
  )
