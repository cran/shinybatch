## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, include = F-------------------------------------------------------
require(shinybatch)

## ---- eval = F----------------------------------------------------------------
#  require(shiny)
#  require(shinydashboard)
#  require(DT)
#  require(shinybatch)
#  
#  # create directory for conf
#  dir_conf <- paste0(tempdir(), "/conf")
#  if (dir.exists(dir_conf)) unlink(dir_conf, recursive = TRUE)
#  dir.create(dir_conf, recursive = T)
#  
#  # get path of the wrapper of th python fun
#  wrapper_path <- system.file("/ex_fun/sb_fun_demo_app_python.R", package = "shinybatch")
#  
#  # init shceduler
#  dir_scheduler <- paste0(tempdir(), "/cron_demo_python")
#  if (dir.exists(dir_scheduler)) unlink(dir_scheduler, recursive = TRUE)
#  dir.create(dir_scheduler, recursive = T)
#  
#  scheduler_add(dir_scheduler = dir_scheduler,
#                dir_conf = dir_conf,
#                max_runs = 1,
#                head_rows = NULL,
#                taskname = "cr_python_demo")

## ---- eval = F----------------------------------------------------------------
#  wrapper_py <- function(vect) {
#    require(reticulate)
#  
#    env <- py_run_file(system.file("/ex_fun/sb_fun_demo_app_python.py", package = "shinybatch")) ;
#    env$apply_regexprs(vect = vect,
#                       regexprs = reticulate::dict(list("input" = "output")))
#  }

## ---- eval = F----------------------------------------------------------------
#  # define UI
#  ui <- shinydashboard::dashboardPage(
#    shinydashboard::dashboardHeader(title = "Shinybatch"),
#    shinydashboard::dashboardSidebar(disable = T),
#    shinydashboard::dashboardBody(
#      fluidRow(
#        shinydashboard::tabBox(width = 12,
#                               tabPanel("Configure tasks",
#                                        fluidRow(
#                                          # conf args
#                                          column(2,
#                                                 numericInput("priority", "Priority",
#                                                              min = 0, max = 10, value = 1, step = 1)
#                                          ),
#                                          column(2,
#                                                 textInput("title", "Title",
#                                                           value = "Task title", width = "100%")
#                                          ),
#                                          column(3,
#                                                 textInput("description", "Description",
#                                                           value = "Task description", width = "100%")
#                                          ),
#                                          # fun args
#                                          column(3,
#                                                 textInput("regexpr", "Regular expression",
#                                                           value = "Test input", width = "100%")
#                                          ),
#                                          column(2,
#                                                 numericInput("sleep_time", "Sleep time (s)",
#                                                              min = 0, max = 30, value = 0, step = 1)
#                                          )
#                                        ),
#                                        hr(),
#                                        fluidRow(
#                                          column(6, offset = 3,
#                                                 actionButton("go_task", "Configure the task", width = "100%")
#                                          )
#                                        )
#  
#                               ),
#                               tabPanel("View tasks",
#                                        fluidRow(
#                                          column(12,
#                                                 tasks_overview_UI("my_id_2")
#                                          )
#                                        ),
#                                        conditionalPanel(condition = "output.launch_task",
#                                                         br(),
#                                                         hr(),
#                                                         fluidRow(
#                                                           conditionalPanel(condition = "output.launch_task",
#                                                                            column(12,
#                                                                                   div(actionButton("show_task", "Display task result", width = "40%"),
#                                                                                       align = "center")
#                                                                            )
#                                                           ),
#                                                           column(12,
#                                                                  conditionalPanel(condition = "input.show_task > 0",
#                                                                                   textOutput("task_text")
#                                                                  )
#                                                           )
#                                                         )
#                                        )
#                               )
#        )
#      )
#    )
#  )

## ---- eval = F----------------------------------------------------------------
#  # define server
#  # call both shinybatch modules + display result
#  server <- function(input, output, session) {
#  
#    # call module to configure a task
#    # connect app inputs to the module
#    callModule(configure_task_server, "my_id_1",
#               btn = reactive(input$go_task),
#               dir_path = dir_conf,
#               conf_descr = reactive(list("title" = input$title,
#                                          "description" = input$description)),
#               fun_path = wrapper_path,
#               fun_name = "wrapper_py",
#               fun_args = reactive(list(vect = input$regexpr)),
#               priority = reactive(input$priority))
#  
#    # call module to view tasks
#    sel_task <- callModule(tasks_overview_server, "my_id_2",
#                           dir_path = dir_conf,
#                           update_mode = "reactive",
#                           allowed_status = c("waiting", "running", "finished", "error"),
#                           allowed_run_info_cols = NULL,
#                           allowed_function_cols = NULL,
#                           allow_descr = T,
#                           allow_args = T)
#  
#    # check if sel_task can be displayed
#    output$launch_task <- reactive({
#      ! is.null(sel_task()) && length(sel_task()) > 0 && sel_task()$status == "finished"
#    })
#    outputOptions(output, "launch_task", suspendWhenHidden = FALSE)
#  
#    # display task
#    output$task_text <- renderText({
#      cpt <- input$show_task
#      sel_task <- sel_task()
#  
#      isolate({
#        if (cpt > 0 && length(sel_task) > 0 && sel_task$status == "finished") {
#          readRDS(paste0(sel_task$path, "/res.RDS"))
#        }
#      })
#    })
#  }

## ---- eval = F----------------------------------------------------------------
#  # launch app
#  shiny::shinyApp(ui = ui,
#                  server = server,
#                  onStart = function() {
#                    onStop(function() {
#                      scheduler_remove(taskname = "cr_python_demo")
#                    })
#                  })

