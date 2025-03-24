technical_notes_content <- function() {
  shiny::tagList(
    tags$h1("Technical Notes"),
    tags$p("A collection of notes and comments on methodology and quality of the analytics data."),
    tags$h2("Data sources"),
    tags$p(
      "The data in this dashboard is pulled from a number of sources, including Google Analytics 4, historical",
      " Google Universal Analytics data, Google Search Console, and web scraping."
    ),
    tags$h2("Sessions"),
    tags$p(
      "A session is defined as a unique user visit to the website. A session is considered to",
      " have ended when there is a 30 minute gap between page views. Meaning that a user returning after that",
      " time will be starting a new session. All session starts events are recorded, as this is done before",
      " any interaction with cookies is possible."
    ),
    tags$h2("Average read time"),
    tags$p(
      "We've followed the methodology used in ",
      shinyGovstyle::external_link("https://pypi.org/project/readtime/", "readtime (PyPi)"),
      " which is based off of Medium's time to read formula (a popular blogging site).",
      " The formula used for read time in seconds is:"
    ),
    tags$code("num_words / 265 * 60 + 12 * num_images"),
    tags$p("This gives 12 seconds per image and num_images is:"),
    tags$code("num_images + num_data_blocks + num_charts"),
    tags$p(
      "In the service each page can have a number of 'data blocks' that can either be just a table, or a chart",
      " and a table. We're treating each chart and table as a separate image for the purposes of measuring."
    ),
    tags$p(
      "We currently haven't found a way to scrape the number of data block charts and tables, so that's",
      " something you'll need to do yourself. Long term we should be able to pull it EES-ily from the EES databases."
    ),
    tags$p(
      "While readtime suggests that the image duration drops down from 12 seconds by 1 second with each",
      " additional image, to a minimum of 3 seconds, we've decided to keep the weighting at 12 seconds as",
      " the 'images' in this case are all charts and tables that are information dense and will need at least",
      " 12 seconds to interpret. If anything we may be underestimating here."
    ),
    tags$p("This doesn't account for the following, so may underestimate the time taken to fully read:"),
    tags$ul(
      tags$li("Pop up modals with explanations"),
      tags$li("Complexity of charts and tables")
    ),
    tags$br(),
    tags$br()
  )
}
