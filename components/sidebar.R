sidebar <- dashboardSidebar(
  width = "400px",
  div(
    style="width:400px; padding: 2rem",
    h2(style ="color:#e6c737",strong("Delaware Diversity Supplier Search Tool")),
    p(em("Apply your filters below and then navigate to either the 'Diversity Supplier Lookup Table' or the 'Diversity Supplier Map' tab to view matching suppliers."))),
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
  checkboxInput(width = "400px",
                "and",
                HTML("Show only businesses that meet <strong><em>all</em></strong> of the selected diversity classifications?"),
                FALSE
  ),
  div(style="width:400px; padding: 2rem",
      actionButton("clear", "Clear all filters",class="btn btn-primary", style="margin:0;color:white", icon = icon("backspace"),width = "100%"))
)