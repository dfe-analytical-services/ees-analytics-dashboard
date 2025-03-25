app <- AppDriver$new(
  name = "downloads",
  expect_values_screenshot_args = FALSE,
  load_timeout = 45 * 1000,
  timeout = 20 * 1000
)

app$wait_for_idle(2000)
app$set_inputs(pages = "Downloads")

files <- c(
  "service_summary_download",
  "pub_summary_download",
  "readtime_download",
  "pub_accordions_download",
  "pub_search_events_download",
  "gsc_time_download",
  "gsc_queries_download",
  "pub_source_download",
  "pub_featured_tables",
  "pub_created_tables"
)

test_that("Can download all files", {
  for (file in files) {
    download_info <- app$get_download(file)
    app$wait_for_idle(50)
    filename <- paste0(Sys.Date(), "_", gsub("_download", ".csv", file))

    expect_equal(basename(download_info), filename)
  }
})
