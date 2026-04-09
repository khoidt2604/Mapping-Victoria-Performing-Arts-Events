library(ggplot2)
library(shiny)
library(leaflet)
library(dplyr)
library(RColorBrewer)
data <- read.csv("AusStage_S12025PE2v2.csv")

# Preprocess once
# Count number of unique events by venue and genre
venue_genre_count <- data %>%
  group_by(Venue.Name, Primary.Genre) %>%
  summarise(Event.Count = n_distinct(Event.Identifier), .groups = 'drop')

# Identify the top 10 venues by total event count
top_venues <- venue_genre_count %>%
  group_by(Venue.Name) %>%
  summarise(Total.Events = sum(Event.Count)) %>%
  arrange(desc(Total.Events)) %>%
  slice_head(n = 10)

# Filter to only include data from top 10 venues
filtered <- venue_genre_count %>%
  filter(Venue.Name %in% top_venues$Venue.Name)

# Reorder factor levels to control bar chart order (most to least)
filtered$Venue.Name <- filtered$Venue.Name <- factor(filtered$Venue.Name, levels = rev(top_venues$Venue.Name))

shinyServer(function(input, output) {
  
  # VIS1 bar chart
  output$vis1Plot <- renderPlot({
    ggplot(filtered, aes(x = Venue.Name, y = Event.Count, fill = Primary.Genre)) +
      geom_bar(stat = "identity") +
      labs(
        title = "Top 10 Most Frequently Used Venues by Event Count",
        x = "Venue Name",
        y = "Number of Events",
        fill = "Primary Genre"
      ) +
      coord_flip() + # Use horizontal bars for better label readability
      theme_minimal()
  })
  
  # Map reactive data
  filteredData <- reactive({
    req(input$yearRange)
    data %>%
      filter(First.Year >= input$yearRange[1], Last.Year <= input$yearRange[2])
  })
  # Aggregate filtered data by venue and genre
  aggregated <- reactive({
    filteredData() %>%
      group_by(Venue.Identifier, Venue.Name, Suburb, Primary.Genre, Latitude, Longitude) %>%
      summarise(Event.Count = n_distinct(Event.Identifier), .groups = "drop")
  })
  # INTERACTIVE MAP
  output$mapPlot <- renderLeaflet({
    # Define color palette using ColorBrewer
    pal <- colorFactor(
      palette = brewer.pal(n = length(unique(data$Primary.Genre)), name = "Set2"),
      domain = data$Primary.Genre
    )
    # Render leaflet map with proportional circle markers
    leaflet(aggregated()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 144.962, lat = -37.8162, zoom = 12) %>% # Melbourne center view
      addCircleMarkers(
        lng = ~Longitude,
        lat = ~Latitude,
        radius = ~sqrt(Event.Count), # Scale circle size by sqrt of event count
        color = ~pal(Primary.Genre),
        stroke = FALSE,
        fillOpacity = 0.6,
        label = ~paste0("<strong>", Venue.Name, "</strong><br>",
                        "Suburb: ", Suburb, "<br>",
                        "Genre: ", Primary.Genre, "<br>",
                        "Events: ", Event.Count),
        labelOptions = labelOptions(direction = "auto")
      ) %>%
      addLegend("bottomright",
                pal = pal,
                values = ~Primary.Genre,
                title = "Primary Genre",
                opacity = 1)
  })
})

