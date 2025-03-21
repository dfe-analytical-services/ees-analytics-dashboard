# UI

# Server


# Old code
# nav_panel(
#   title = "By publication",
#   layout_sidebar(
#     sidebar = sidebar(
#       title = "Options",
#       selectInput(
#         "publication_choice",
#         label = p(strong("Choose a publication")),
#         choices = "loading...",
#         selected = NULL
#       ),
#       radioButtons(
#         "P_date_choice",
#         "Choose date range",
#         c(
#           "week",
#           "four_week",
#           "since_4thsep",
#           "six_month",
#           "one_year",
#           "all_time"
#         ),
#         selected = "six_month"
#       ),
#     ),
#     alert(
#       status = "warning",
#       tags$b("This app is changing!"),
#       tags$p(
#         paste(
#           "Following the move to GA4 (from universal analytics) we've had to revisit all",
#           "the data underpinning this app, we are working on bringing back the same level",
#           "of information you've had previously. Let us know what is most important for you",
#           "by emailing "
#         ),
#         a(
#           href = "mailto:explore.statistics@education.gov.uk",
#           "explore.statistics@education.gov.uk.",
#           target = "_blank"
#         )
#       )
#     ),
#     layout_columns(
#       value_box(
#         title = tooltip(
#           span(
#             "Number of sessions",
#             bsicons::bs_icon("question-circle-fill")
#           ),
#           paste(
#             "The total number of sessions. This is only applicable to the service as a",
#             "whole - sessions are only counted for entry pages in the Google Analytics",
#             "data. Sessions have a 24 hour limit, a session lasting 25 hours would count",
#             "as two sessions."
#           ),
#           placement = "bottom"
#         ),
#         value = textOutput("P_num_sessions")
#       ),
#       value_box(
#         title = tooltip(
#           span(
#             "Number of pageviews",
#             bsicons::bs_icon("question-circle-fill")
#           ),
#           "The total number of pageviews.",
#           placement = "bottom"
#         ),
#         value = textOutput("P_num_pageviews")
#       ),
#     ),
#     layout_columns(
#       card(card_header(
#         "Sessions",
#         tooltip(
#           bs_icon("info-circle"),
#           paste(
#             "The total number of sessions. This is only applicable to the service as a whole",
#             "- sessions are only counted for entry pages in the Google Analytics data. Sessions",
#             "have a 24 hour limit, a session lasting 25 hours would count as two sessions."
#           ),
#         )
#       ), plotOutput("P_S")),
#       card(card_header(
#         "Page views", tooltip(bs_icon("info-circle"), "The total number of pageviews.")
#       ), plotOutput("P_PV")),
#       col_widths = c(6, 6)
#     ),
#     layout_columns(
#       tableOutput("pub_pageview_table"),
#       tableOutput("pub_session_table"),
#       col_widths = c(6, 6)
#     )
#   )
# ),


# -------------------------------------------------------


# # Dropdown options =========================================================
# publications <- reactive({
#   publication_data() |>
#     distinct(publication) |>
#     str_sort()
# }) |>
#   bindCache(last_updated_date(), publication_data())
#
# # Outputs ===================================================================
#
# observe({
#   updateSelectInput(
#     session,
#     "publication_choice",
#     choices = publications()
#   )
# })
# output$P_num_sessions <- renderText({
#   paste0(
#     dfeR::comma_sep(
#       publication_data() %>%
#         as.data.frame() %>%
#         summarise(sum(sessions))
#     )
#   )
# })
#
# output$P_num_pageviews <- renderText({
#   paste0(
#     dfeR::comma_sep(
#       publication_data() |>
#         as.data.frame() |>
#         summarise(sum(pageviews))
#     )
#   )
# })
#
# output$P_S <- renderPlot({
#   ggplot(
#     publication_data(),
#     aes(x = date, y = sessions)
#   ) +
#     geom_line(color = "steelblue") +
#     xlab("") +
#     theme_minimal() +
#     theme(legend.position = "top")
# })
#
# output$P_PV <- renderPlot({
#   ggplot(
#     publication_data(),
#     aes(x = date, y = pageviews)
#   ) +
#     geom_line(colour = "steelblue") +
#     xlab("") +
#     theme_minimal() +
#     theme(legend.position = "top")
# })
#
# output$pub_pageview_table <- renderTable({
#   publication_data() |> select(date, pagePath, pageviews)
# })
#
# output$pub_session_table <- renderTable({
#   publication_data() |> select(date, sessions)
# })
