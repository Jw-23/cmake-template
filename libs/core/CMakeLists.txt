add_library(project_core src/simple.cpp)
add_library(project::core ALIAS project_core)

target_include_directories(
  project_core
  PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<INSTALL_INTERFACE:include>"
)

target_link_libraries(project_core PRIVATE project_options project_warnings)
