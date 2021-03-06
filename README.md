# CA Aquaculture Dashboard

The California Aquaculture Dashboard is a data exploration tool for visualizing California-specific aquaculture data.


# Repository Structure 
**ui.R, server.R**

Main components of the shiny dashboard. The UI is the user interface for the shiny app, including layout and text elements. The server for shiny app is where you add custom, interactive charts and maps for each goal.

**global.R**

Contains global set-up, libraries, color palettes, and final wrangling.

**front_page.R**

Edit this script to change the content in the homepage (The OHI Story). Elements are customized in www/custom.css


## modules
**modules/summary_stats_card.R**

Creates the summary statistics shiny output. Define stats and text each time. Contains a ui and server-associated function.

**modules/chart_card.R**

Creates graphs that can be recycled for each goal. Contains a ui and server-associated function.

**modules/map_card.R**

Creates maps that can be recycled for each goal. Contains a ui and server-associated function.


## functions
**functions/tab_title.R**

Creates the header or information section in each tab.


## slidedeck
**slidedeck/modules_slidedeck.Rmd**

Add or edit the `xaringan` presentation. Knit to html for viewing in browser

**slidedeck/modules_slidedeck.html**

View slide deck tutorial for the global dashboard shiny app.

 
## www
**www/custom.css**

Define html classes here to customize elements in the global-dashboard. www/img
Images that are called by CSS in front_page.R.


## int
_Folder for storing wrangled data tables._


## tmp
_Folder for testing code._

**tmp/test_global_map.Rmd**

To test the leaflet map with global data. 

**tmp/summary_stats.Rmd**

Use to wrangle data and derive stats for summary stats module.

**tmp/test_front_pg.R**

Use to test front page css code.
