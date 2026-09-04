add_executable(project_benchmarks benchmark_add.cpp)
set_target_properties(
  project_benchmarks PROPERTIES OUTPUT_NAME "${PROJECT_NAME}_benchmarks"
)
target_link_libraries(
  project_benchmarks
  PRIVATE benchmark::benchmark_main project_core project_options project_warnings
)
