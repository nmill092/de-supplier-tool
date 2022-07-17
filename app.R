source("global.r", local = T)


ui <- dashboardPage(
  dashboardHeader(title = "Delaware Diversity Supplier Portal",disable = T),
  dashboardSidebar(width = "400px",
                   div(
                     style="width:400px; padding: 2rem",
                     h2(strong("Delaware Diversity Supplier Search Tool")),
                     p("The data in this dashboard are sourced from the Delaware Office of Supplier Diversity's Certified Vendors API. Businesses included are owned and controlled 51% or more by minorities, women, veterans, and individuals with disabilities."),
p("Use the filters below to select one or more diversity classifications. You can further  trim down your search by filtering for particular industries or cities within the State of Delaware."),
p("This is an independent project which is in no way affiliated with the State Government of Delaware.")),
 div(style="width:400px; padding: 2rem",
   icon("github","fa-2x")
 ),
    selectizeInput(width = "400px",
      "owned",
      "Select one or more diversity classifications:",
      choices = list(
        "Woman-Owned" = "wbe",
        "Minority-Owned" = "mbe",
        "Disability-Owned" = "disabled",
        "Veteran-Owned" = "veteran",
        "Black-Owned" = "african",
        "Asian American-Owned" = "asian",
        "Native American-Owned" = "nativeamer",
        "Hispanic American-Owned" = "hispanic",
        "Subcontinent Asian American-Owned" = "subasian"
      ),
      multiple = T
    ),
    
    checkboxInput(width = "400px",
      "and",
      "Show only businesses that meet all of the selected diversity classifications?",
      FALSE
    ),
    selectizeInput(width="400px",
      "naics",
      "Select an industry:",
      choices = NULL,
      multiple = T
    ),
    selectizeInput(width="400px",
                   "city",
                   "Select a city:",
                   choices = NULL,
                   multiple = T
    ),
    actionButton("clear", "Clear all filters",icon = icon("backspace"),width = "250px")
  ),
  dashboardBody(
    tags$head(includeCSS("www/styles.css"), 
              includeScript("script.js")),
    useShinyjs(),
    fluidRow(
      box(height = "20vh",
        title = "Diversity Supplier Map",
        status = "primary",
        collapsible = T,
        width = 12,
        withSpinner(
          leafletOutput("map"),
          type = 7,
          color.background="white")
      )
    ),
    fluidRow(box(
      title = "Table",
      width = 12,
      withSpinner(
        reactableOutput("reactable"),
        type = 7,
        color.background = "white"
      )
    ))
  ),
 footer = dashboardFooter(left = "View Github Repo",)
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  de.data <-
    fromJSON(
      URLencode(
        "https://data.delaware.gov/resource/s4ev-nzhm.json?$where=state = 'DE'"
      )
    )
  
  de.data$geocoded_location$coordinates[sapply(de.data$geocoded_location$coordinates, is.null)] <-
    NA
  
  de.data$lng <-
    unlist(lapply(de.data$geocoded_location$coordinates, `[`, 1))
  de.data$lat <-
    unlist(lapply(de.data$geocoded_location$coordinates, `[`, 2))
  de.data$geocoded_location <- NULL
  de.data$job_description[is.na(de.data$job_description)] <-
    "No description available."
  de.data$website <-
    gsub("http:\\/\\/|www.|https:\\/\\/",
         "http://",
         de.data$website)
  
  f <- function(x)
    if_else(is.na(x), F, T)
  
  vars.to.match <-
    "wbe|mbe|hispanic|nativeamer|asian|veteran|african|subasian|disabled"
  de.data <- de.data %>% mutate_at(vars(matches(vars.to.match)), f)
  de.data$company_name <- gsub("�", "'", de.data$company_name)
  de.data$job_description <- gsub("�", "'", de.data$job_description)
  de.data$city[de.data$city == "New Castle,"] <- "New Castle"
  de.data$city[de.data$city == "Millsoboro"] <- "Millsboro"
  
  
  de.data <- de.data %>%
    mutate(naics_root = substr(naicscode1, 1, 5))  %>%
    left_join(naics, by = c("naics_root" = "NAICS")) %>%
    rename('naics_title' = "2017 NAICS Short Title")
  
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
          "<h4 style='font-weight:bold'>%s</h4>
    <p>%s, %s, %s %s</p><button>Show in Table</button>",
    company_name,
    address_1,
    city,
    state,
    zip_code),
    clusterOptions = markerClusterOptions(freezeAtZoom = 10, 
                                          showCoverageOnHover = T)
      )
  })
  
  
  observe({
    leafletProxy("map",
                 data = filtered()) %>%
      clearMarkers() %>% 
      clearMarkerClusters() %>%
      addMarkers(
        layerId = ~ osdcertnum,
        label = ~ company_name,
        popup = ~ sprintf(
          "<h4>%s</h4>
    <p>%s, %s, %s %s</p><button onclick='moreInfo(\"%s\", \"%s\")'>Show In Table</button>",
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
      ) %>% setView(lng = mean(filtered()$lng), lat = mean(filtered()$lat), zoom = 9)
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
            "function(rowInfo, column, state) { return renderDetails(rowInfo,column,state) }"
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
          cell = JS("function(rowInfo) { return renderBadges(rowInfo).html }")
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
      theme = reactableTheme(
        searchInputStyle = list(width = "100%", padding="10px"),
        cellPadding = "10px",headerStyle = list(padding="12px")
      ),
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
    shinyjs::runjs("document.documentElement.scrollTop = 0; document.body.scrollTop = 0")
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
