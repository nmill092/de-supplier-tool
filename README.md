# Delaware Diversity Supplier Tool 

*View this app live on [shinyapps.io](https://fum725-nilemill.shinyapps.io/DE-Diversity-Supplier-Tool/).*

## Overview

This app uses [data from the Delaware Office of Supplier Diversity](https://data.delaware.gov/Economic-Development/Certified-Vendors-Office-of-Supplier-Diversity/s4ev-nzhm) to help users identify certified diverse suppliers within the state of Delaware. Access to the dataset, which is updated daily, is provided via the Socrata Open Data API. Diversity classifications captured by the app include: 
* Minority-owned businesses
* Women-owned businesses
* Disabled-owned businesses
* Veteran-owned businesses
* Asian American-owned businesses
* Black-owned businesses 
* Hispanic American-owned businesses
* Subcontinent Asian American-owned businesses

You can filter on one or more of the above classifications and can further refine your search by specifying a location/industry. 

The scaffolding of the interface is created using `shinydashboard`. The table is generated using [`reactable`](https://glin.github.io/reactable/). The company detail block that appears upon expanding each of the rows is rendered with JavaScript, as are the "badges" that appear in the "Diversity Classifications" column. 

Work still needs to be done to make the tool responsive and ensure that the filters are still accessible on smaller screens. Additionally, the behavior of the map when changing/clearing filters, searching, etc. needs to be fine-tuned to prevent disorientation (ideally, the map should reset to its initial orientation as filters are cleared). 

## R Libraries used 

* shiny
* shinyjs
* shinycssloaders
* shinyWidgets
* readr
* dplyr
* reactable
* reactablefmtr
* jsonlite
* leaflet
