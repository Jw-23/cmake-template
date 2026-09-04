add_executable(project_app src/main.cpp)

set_target_properties(project_app PROPERTIES OUTPUT_NAME "${PROJECT_NAME}")

target_link_libraries(
  project_app
  PRIVATE project_core project_options project_warnings
)

if(PROJECT_ENABLE_SPDLOG)
  target_compile_definitions(project_app PRIVATE PROJECT_HAS_SPDLOG=1)
  target_link_libraries(project_app PRIVATE spdlog::spdlog)
endif()

if(PROJECT_ENABLE_FMT)
  target_compile_definitions(project_app PRIVATE PROJECT_HAS_FMT=1)
  target_link_libraries(project_app PRIVATE fmt::fmt)
endif()

if(PROJECT_ENABLE_EIGEN)
  target_compile_definitions(project_app PRIVATE PROJECT_HAS_EIGEN=1)
  target_link_libraries(project_app PRIVATE Eigen3::Eigen)
endif()
