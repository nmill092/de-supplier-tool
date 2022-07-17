source("global.r", local = T)


ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(collapsed = TRUE),
  dashboardBody(
    tags$head(includeCSS("www/styles.css"), includeScript("script.js")),
    fluidRow(
      box(
        title = "map",
        width = 12,
        verbatimTextOutput("verb"),
        leafletOutput("map"),
        selectizeInput(
          "owned",
          "Select a diversity:",
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
        checkboxInput(
          "and",
          "Show only businesses that meet all of the conditions selected above?",
          FALSE
        )
      )
    ),
    fluidRow(box(
      title = "Table",
      width = 12,
      withSpinner(
        reactableOutput("distPlot"),
        type = 7,
        color.background = "white"
      )
    ))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
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
  de.data$job_description[is.na(de.data$job_description)] <- "No description available."
  de.data$website <- gsub("http:\\/\\/|www.|https:\\/\\/","http://",de.data$website)
  
  f <- function(x) if_else(is.na(x), F, T)
  
  vars.to.match <-
    "wbe|mbe|hispanic|nativeamer|asian|veteran|african|subasian|disabled"
  de.data <- de.data %>% mutate_at(vars(matches(vars.to.match)), f)
  de.data$company_name <- gsub("�", "'", de.data$company_name)
  de.data$job_description <- gsub("�","'",de.data$job_description)
  
  naics <- read_csv("2017_titles_descriptions.csv")
  
  de.data <- de.data %>% 
    mutate(naics_root = substr(naicscode1,1,5))  %>% 
    left_join(naics, by = c("naics_root" = "NAICS")) %>% 
    rename('naics_title' = "2017 NAICS Short Title")
  
  filtered <- reactive({
    if (length(input$owned) == 0) {
      de.data
    } else {
      de.data$num <- rowSums(de.data[input$owned])
      if (input$and == F) {
        de.data[de.data$num > 0,]
      } else {
        de.data[de.data$num == length(input$owned),]
      }
    }
  })
  
  output$verb <- renderText({
    getReactableState("distplot")$selected
  })
  
  labels <- sprintf(
    "<strong>%s</strong><pre>%s</p>",
    de.data$company_name,
    de.data$job_description
  ) %>%
    lapply(htmltools::HTML)
  
  output$map <- renderLeaflet({
    leaflet(de.data) %>%
      addProviderTiles("CartoDB") %>%
      addMarkers(label = labels)
  })
  
  output$distPlot <- renderReactable({
    reactable(
      filtered() %>%
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
        )
      ,
      defaultColDef = colDef(show = F, 
                             headerClass = "header",
                             ),
      onClick = "expand",
      selection = "multiple",
      columns = list(
        company_name = colDef(
          searchable = F,
          filterable = F,
          show = T,
          resizable = T,
          name = "Company Name",
          rowHeader = T,sticky = "left"
        ),
        details = colDef(
          show = T,
          html = T,
          maxWidth = 30,
          filterable = F,
          searchable = F,
          name = "",
          details = JS(
            "function(rowInfo, column, state) { 
            return `
            <div class='row-details'>
            <div class='company-header'>
<h4>${rowInfo.values.company_name}</h4>
<span class='company-address'> <i class='fas fa-map-marker-alt'></i>
${rowInfo.values.address_1}, ${rowInfo.values.city}, ${rowInfo.values.state} ${rowInfo.values.zip_code}
</span>
</div>
<div class='company-body'>
 <div class='tag-group'><strong>Tags: </strong> ${renderBodyTags(rowInfo)}</div>
<div class='industry'><strong>Primary NAICS Industry Description: </strong> ${rowInfo.values.naics_title}</div>
<div class='contact-group'>
  <div>
     <span class='contact-item'><i class='fas fa-phone-square-alt'></i> ${rowInfo.values.tel}</span>  <span class='contact-item'><i class='fas fa-desktop'></i> ${rowInfo.values.website==null ? 'No website available' : '<a href='+rowInfo.values.website+' target=\"_blank\">'+rowInfo.values.website.split(\"http://\")[1]+'</a>'}</span></div>
</div> 
</div>
<hr/>
 <div class='company-description'>
  <h4>Company Description</h4>
  <p><em>${rowInfo.values.job_description}</em></p>
</div>
<hr/>
<div class='company-footer'>
  <h4 style='font-size: 1.5rem; color:#696969'>Additional Information</h4>
 <div>
  <span style='display:block'><strong>OSD Certification Number:</strong> ${rowInfo.values.osdcertnum}</span>

  <span class='contact-item' style='margin-top: 0rem; display:block'><strong>ATTN:</strong> ${rowInfo.values.contact_name}, <a href='mailto:${rowInfo.values.email}'>${rowInfo.values.email}</a></span></div>
</div>
</div>
</div>
            ` }")
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
          name = "",
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
      theme = fivethirtyeight(cell_padding = "11px"),
      showSortable = T
    )
  })
  

  
  selected <- reactive({
    req(input$details)
    
    de.data[de.data$osdcertnum == input$details,]
  })
}

# Run the application
shinyApp(ui = ui, server = server)
