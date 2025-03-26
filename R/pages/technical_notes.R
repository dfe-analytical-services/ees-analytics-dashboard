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
      " time will be starting a new session."
    ),
    tags$h2("Pageviews"),
    tags$p(
      "A pageview is counted each time a page is loaded or reloaded in the browser. This includes",
      " repeated views of the same page by the same user."
    ),
    tags$h2("7 day rolling averages"),
    tags$p(
      "We calculate a 7 day rolling average for sessions and pageviews to smooth out the data and make it easier",
      " to see trends over time. This is calculated by taking the average of the current day plus the previous 6",
      " days."
    ),
    tags$h2("Source and medium"),
    tags$p(
      "The source and medium are defined by Google Analytics 4, and are the source of the user visit and the",
      " medium of the visit. For example, a user might come from a search engine (source) and the medium might",
      " be organic search. This is useful for understanding where users are coming from and how they are finding",
      " the website."
    ),
    tags$p("Within source and medium data there are a few different options for no data:"),
    tags$ul(
      tags$li("(direct) - the user has clicked on a link in an email or a document"),
      tags$li("(none) - there is no referrer data, e.g. a user has typed the URL directly into the browser"),
      tags$li("(not set) - when the source and medium may exist, but are not known")
    ),
    tags$h2("Google searches (Google Search Console)"),
    tags$p(
      "We show the top Google searches by clicks and appearances for the service and for each publication, at
      publication level these are the searches that the URL is currently appearing for, and gives a sense of the
      existing traffic. It's important to note that it does not capture the users who might be searching for our
      statistics and not finding them as we're not appearing highly enough in the results."
    ),
    tags$h2("Accordion clicks"),
    tags$p(
      "We track each time a user clicks to open or close an accordion. Be aware that as we only track the",
      " accordions by name, that any accordions that have shared the same name will be combined together."
    ),
    tags$h2("Table tool and featured tables"),
    tags$p(
      "Currently we are only able to track table tool creation events at that point we can track the file used",
      ", but nothing more."
    ),
    tags$p(
      "In some instances, long publication and filenames have led to names getting truncated.",
      " We can track featured tables when they are clicked from the table tool page, however",
      " it is not currently possible to get the number of times users access featured tables or fast-track (explore",
      " this data green buttons) from release pages. We don't have access to the publication information to join on",
      " to currently."
    ),
    tags$p(
      "We're working on implementing our own tracking of table tool events to give us more reliable and",
      " fine-grained data."
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
