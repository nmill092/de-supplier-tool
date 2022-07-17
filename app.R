source("global.r", local = T)
source("sidebar.R", local=T)
source("tab1.R", local=T)

ui <- dashboardPage(
  dashboardHeader(title = "Delaware Diversity Supplier Lookup Tool", disable = T),
  sidebar = sidebar, 
  dashboardBody(
    tags$head(includeCSS("styles.css"), 
              includeScript("script.js")),
    useShinyjs(),
    fluidRow(
      tabBox(id = "tabset",
             width=12, 
             height = "100%",
      tabPanel1,
      tabPanel("Diversity Supplier Lookup Table",
      p(strong("Click on any supplier from the table below to view detailed information."), br(),br(), em("Note: Websites, email addresses, and other contact information is provided by the Delaware Office of Supplier Diversity. For questions about the accuracy of information in this dataset, please ", a(href="https://data.delaware.gov/Economic-Development/Certified-Vendors-Office-of-Supplier-Diversity/s4ev-nzhm",target="_blank", "contact the dataset owner."))),
      withSpinner(
        reactableOutput("reactable"),
        type = 7,
        color.background = "white")
    ),
    tabPanel("Diversity Supplier Map",
             p("To view more information about a specific supplier, click on a marker from the map below and then click the 'Show in Table' button."),
             withSpinner(
               leafletOutput("map"),
               type = 7,
               color.background="white")
    ))
  ))
)

server <- function(input, output, session) {

  
  filtered <- reactive({
    data <- de.data
    
    if (length(input$owned) == 0) {
      data
    } else {
      data$num <- rowSums(data[input$owned])
      if (input$and == F) {
        data <- data[data$num > 0,]
      } else {
        data <- data[data$num == length(input$owned), ]
      }
    }
    
    if (length(input$naics) > 0) {
     data <-  data[data$naics_title %in% input$naics, ]
    } else {
      data <- data
    }
    
    if(length(input$city) > 0) {
      data[data$city %in% input$city,]
    } else {
      data
    }
  })
  
  
  output$map <- renderLeaflet({
    leaflet(de.data) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addMarkers(
        layerId = ~ osdcertnum,
        label = ~ company_name,
        popup = ~ sprintf(
          "<h4>%s</h4>
    <p>%s, %s, %s %s</p>
    <button class='new-btn' onclick='moreInfo(\"%s\", \"%s\")'>Show In Table</button>",
    company_name,
    address_1,
    city,
    state,
    zip_code,
    osdcertnum,
    company_name),
    clusterOptions = markerClusterOptions(freezeAtZoom = 10, 
                                          showCoverageOnHover = T)
      )
  })
  
  
  observe({
    if(nrow(filtered()!=0)) {
    leafletProxy("map",
                 data = filtered()) %>%
      clearMarkers() %>% 
      clearMarkerClusters() %>%
      addMarkers(
        layerId = ~ osdcertnum,
        label = ~ company_name,
        popup = ~ sprintf(
          "<h4>%s</h4>
    <p>%s, %s, %s %s</p>
    <button class='new-btn' onclick='moreInfo(\"%s\", \"%s\")'>Show In Table</button>",
    company_name,
    address_1,
    city,
    state,
    zip_code,
    osdcertnum,
    company_name),
    clusterOptions = markerClusterOptions(
      showCoverageOnHover = T,
      spiderfyOnMaxZoom = T
    )
      ) %>% setView(lng = mean(filtered()$lng), lat = mean(filtered()$lat), zoom = 9)}
  })
  
  output$reactable <- renderReactable({
    reactable(
      de.data %>%
        mutate(badges = "", details = "") %>%
        select(
          osdcertnum,
          mbe,
          wbe,
          hispanic,
          nativeamer,
          asian,
          veteran,
          african,
          subasian,
          disabled,
          details,
          company_name,
          city,
          address_1,
          zip_code,
          state,
          contact_name,
          email,
          badges,
          website,
          tel,
          naics_title,
          job_description
        ),
      defaultColDef = colDef(show = F,
                             headerClass = "header",),
      onClick = "expand",
      selection = "multiple",
      searchable = T,
      columns = list(
        company_name = colDef(
          searchable = T,
          filterable = F,
          show = T,
          resizable = T,
          name = "Company Name",
          rowHeader = T,
          sticky = "left"
        ),
        details = colDef(
          show = T,
          html = T,
          maxWidth = 30,
          filterable = F,
          name = "",
          details = JS(
            "function(rowInfo, column, state) { 
            return renderDetails(rowInfo,column,state) 
            }"
          )
        ),
        city = colDef(
          name = "City",
          show = T,
          filterable = F,
          searchable = F
        ),
        badges = colDef(
          searchable = F,
          sortable = F,
          name = "Diversity Classifications",
          filterable = F,
          show = T,
          html = T,
          cell = JS("function(rowInfo) { 
                    return renderBadges(rowInfo).html 
                    }")
        )
      ),
      highlight = T,
      wrap = T,
      showSortIcon = T,
      filterable = TRUE,
      rowStyle = list(cursor = "pointer"),
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 20, 50, 100),
      showSortable = T,
      theme=nytimes(),
      # theme = reactableTheme(
      #   searchInputStyle = list(width = "100%", padding="10px"),
      #   cellPadding = "10px",headerStyle = list(padding="12px")
      # ),
      language = reactableLang(searchPlaceholder = "Search for a company name",
                               noData = "No companies match your selected criteria.")
    )
  })
  
  observe({
    updateReactable("reactable", data = filtered(), expanded = F)
  })
  
  observeEvent(input$clear, {
    reset("naics")
    reset("owned")
    reset("city")
    updateReactable("reactable", data = filtered(), expanded = F)
    
  })
  
  observeEvent(input$selected, {
    updateReactable("reactable",
                    data = filtered()[filtered()$osdcertnum == input$selected, ], expanded = T)
  })
  

  
  output$text <- renderPrint({
    getReactableState("reactable")
  })
  
  updateSelectizeInput(session = session,
                       inputId = "naics",
                       choices = sort(unique(de.data$naics_title)))
  
  updateSelectizeInput(session = session,
                       inputId = "city",
                       choices = sort(unique(de.data$city)))
  
  selected <- reactive({
    req(input$details)
    
    de.data[de.data$osdcertnum == input$details, ]
  })
}

# Run the application
shinyApp(ui = ui, server = server)
