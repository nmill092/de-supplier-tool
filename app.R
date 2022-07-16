source("global.r",local = T)


ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(collapsed = TRUE),
  dashboardBody(
    tags$head(includeCSS('www/styles.css'), includeScript("script.js")),
    fluidRow(box(title="map",
             width = 12, 
             verbatimTextOutput("verb"),
             leafletOutput("map"),
             selectInput("owned", 
                         "Select a diversity:",
                         choices = list("Woman-Owned" = "wbe",
                                        "Minority-Owned" = "mbe",
                                        "Disability-Owned" = "disabled",
                                        "Veteran-Owned" = "veteran",
                                        "Black-Owned" = "african",
                                        "Asian American-Owned" = "asian",
                                        "Native American-Owned" = "nativeamer",
                                        "Hispanic American-Owned" = "hispanic",
                                        "Subcontinent Asian American-Owned" = "subasian"
                                        ),
                         multiple = T),
             checkboxInput("and", "Show only businesses that meet all of the conditions selected above?", FALSE))),
    fluidRow(
      box(title = "Table",width = 12,
       withSpinner(reactableOutput("distPlot"),type = 7,color.background = "white")
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  de.data <- fromJSON(URLencode("https://data.delaware.gov/resource/s4ev-nzhm.json?$where=state = 'DE'"))
  
  de.data$geocoded_location$coordinates[sapply(de.data$geocoded_location$coordinates, is.null)] <- NA
  
  de.data$lng <- unlist(lapply(de.data$geocoded_location$coordinates,`[`, 1))
  de.data$lat <- unlist(lapply(de.data$geocoded_location$coordinates,`[`, 2))
  de.data$geocoded_location <- NULL
  
  f <- function(x) if_else(is.na(x), F, T)
  
  
  vars.to.match <- "wbe|mbe|hispanic|nativeamer|asian|veteran|african|subasian|disabled"
  de.data <- de.data %>% mutate_at(vars(matches(vars.to.match)),f)
  
  
  filtered <- reactive({ 
    
    if(length(input$owned)==0) {
      de.data
    } else {
    de.data$num <- rowSums(de.data[input$owned])
    if(input$and == F) { 
    de.data[de.data$num > 0,]
    } else {
      de.data[de.data$num==length(input$owned),]
    }
    }
    
    
    })
  
  output$verb <- renderText({ 
    paste(input$owned, length(input$owned))
    })
  
  labels <- sprintf('<strong>%s</strong><pre>%s</p>',de.data$company_name,de.data$job_description) %>% lapply(htmltools::HTML)
   
  output$map <- renderLeaflet({ 
    leaflet(de.data) %>% 
      addProviderTiles("CartoDB") %>% addMarkers(label = labels)
    })

    output$distPlot <- renderReactable({
      
      reactable(filtered() %>% 
                       select(osdcertnum, 
                              mbe, 
                              wbe, 
                              hispanic, 
                              nativeamer, 
                              asian, 
                              veteran, african, subasian, disabled, company_name, city, website, job_description) %>% 
                       mutate(badges = "", details=""),
                defaultColDef = colDef(show = F),
                columns = list(
                 company_name = colDef(show=T),
                 details = colDef(show=T, 
                                  html=T, 
                                  details = JS("
                                                 function(rowInfo) {
                                                 return `
                                                 <div class='row-details'>
                                                 <strong>${rowInfo.values.company_name}</strong>
                                               <p><em>${rowInfo.values.job_description}</em></p>
                                                </div>`
                                                 }
                                                 ")),
                 city = colDef(show=T),
                  badges = colDef(show=T, html=T, cell = JS("renderBadges"))),
                highlight = T,  wrap = T,showSortIcon = T,
                filterable = TRUE,
                theme = reactableTheme(
                  borderColor = "#dfe2e5",
                  stripedColor = "#f6f8fa",
                  highlightColor = "#f0f5f9",
                  cellPadding = "8px 12px",
                  style = list(fontFamily = "Source Sans, -apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif"),
                  searchInputStyle = list(width = "100%")
                ),
                onClick = JS("function(el) {
                             let descrip = el.values.job_description;
                             Shiny.setInputValue('details',el.values.osdcertnum)
                            
                             Shiny.setInputValue('test', 'true', {priority: 'event'})
                             let websiteRegex = /https:\\/\\/|http:\\/\\/|www\\./
                             if(el.values.website !== 'NA' && el.values.website !== 'null') {
                             let link = el.values.website.replace(websiteRegex,'');
                             
                            /* document.querySelector('#example').innerHTML += 
                             `<a href=http://${link} target='_blank' class='siteBtn' style='display:block'>Go to website</a>` 
                              document.querySelector('#example').classList.remove('appear');
      void document.querySelector('#example').offsetWidth;
  document.querySelector('#example').classList.add('appear'); */
                             }
                             }"))
    })
    
    
    selected <- reactive({
      req(input$details)
      
      de.data[de.data$osdcertnum == input$details,]
   
    })
    
    output$flags <- renderUI({
      
      tag <- div()
      
     
      if(selected()$city=="Wilmington") {
       tag <-  tag %>% tagAppendChild(icon("check"))
      }

      tag
      })
    
 
    
 
    
    # observeEvent(input$test, { 
    #   showModal(
    #     modalDialog(
    #       de.data$job_description[de.data$osdcertnum==input$details],easyClose = T
    #     )
    #   )
    #   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)
