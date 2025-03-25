app <- AppDriver$new(
  name = "no_errors",
  expect_values_screenshot_args = FALSE,
  load_timeout = 45 * 1000,
  timeout = 20 * 1000
)

app$wait_for_idle(2000)

# Technical notes page ========================================================
app$set_inputs(pages = "Technical notes")
app$wait_for_idle(1000)

# Service summary tabs ========================================================
app$set_inputs(pages = "Service summary")
app$wait_for_idle(1000)
app$set_inputs(service_tabs = "Devices")
app$wait_for_idle(1000)
app$set_inputs(service_tabs = "Referrals")
app$wait_for_idle(1000)
app$set_inputs(service_tabs = "Google search")
app$wait_for_idle(1000)
app$set_inputs(service_tabs = "Page types")
app$wait_for_idle(1000)
app$set_inputs(service_tabs = "Overview")
app$wait_for_idle(1000)
app$set_inputs(service_date_choice = "All time")
app$wait_for_idle(1000)

# Publication tabs ============================================================
app$set_inputs(pages = "Publication analytics")
app$wait_for_idle(1000)
app$set_inputs(pub_name_choice = "Apprenticeships")
app$wait_for_idle(1000)
app$set_inputs(pub_date_choice = "All time")
app$wait_for_idle(1000)
app$set_inputs(pub_tabs = "Content interactions")
app$wait_for_idle(1000)
app$set_inputs(pub_tabs = "Accordion clicks")
app$wait_for_idle(1000)
app$set_inputs(pub_tabs = "Searches")
app$wait_for_idle(1000)
app$set_inputs(pub_tabs = "Referrals")
app$wait_for_idle(1000)
app$set_inputs(pub_tabs = "Tables")
app$wait_for_idle(1000)

test_that("There were no errors while navigating the app", {
  expect_null(app$get_html(".shiny-output-error"))
  expect_null(app$get_html(".shiny-output-error-validation"))
})
