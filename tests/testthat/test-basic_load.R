# Start an app running ========================================================
app <- AppDriver$new(
  name = "basic_load_nav",
  expect_values_screenshot_args = FALSE,
  load_timeout = 45 * 1000,
  timeout = 20 * 1000
)

app$wait_for_idle(2000)

test_that("App loads and title of app appears as expected", {
  expect_equal(app$get_text("title"), "Explore education statistics analytics")
})

test_that("There are no errors on load", {
  # This may give false positives in GitHub actions...
  expect_null(app$get_html(".shiny-output-error"))
  expect_null(app$get_html(".shiny-output-error-validation"))
})
