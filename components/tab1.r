tabPanel1 <- tabPanel("About this Tool", 
         h3(strong("Welcome to the Delaware Diversity Supplier Lookup Tool!")),
         p("The data in this dashboard are sourced from the Delaware Office of Supplier Diversity's Certified Vendors API. Businesses included are owned and controlled 51% or more by minorities, women, veterans, and individuals with disabilities."),
         p("Use the filters on the left to select one or more diversity classifications. You can further  trim down your search by filtering for particular industries (as defined within the NAICS) or cities within the State of Delaware."),
         p("This is an independent project which is in no way affiliated with the State Government of Delaware."),
         tags$button("Explore Suppliers", class="new-btn", onclick=JS('document.querySelector(\'[data-value=\"Diversity Supplier Lookup Table\"\').click()')),
         hr(),
         h4("Additional information and resources"),
         withTags(
           ul(style='list-style:none',
              li(a(href='https://business.delaware.gov/osd-search/', target="_blank", style="display:block",  icon("external-link-alt"), "Delaware Office of Supplier Diversity: Search the Directory")),
              li(a(href='https://business.delaware.gov/find/', target="_blank", style="display:block", icon("external-link-alt"), "Resources for Small Businesses in Delaware")),
              li(a(href='https://data.delaware.gov/Economic-Development/Certified-Vendors-Office-of-Supplier-Diversity/s4ev-nzhm', target="_blank", style="display:block", icon("external-link-alt"), "Additional Information about the Data")))),
)