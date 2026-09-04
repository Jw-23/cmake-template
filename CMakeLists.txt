cmake_minimum_required(VERSION 3.24)

# This line is updated by install.sh. Keep the variable separate from project()
# so project names containing '-' remain valid CMake target output names.
set(CMAKE_TEMPLATE_PROJECT_NAME "cmake_template")
project("${CMAKE_TEMPLATE_PROJECT_NAME}" VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Keep clangd's compilation database at a stable path even when presets use
# build/debug, build/release, or a custom binary directory.
set(PROJECT_COMPILE_COMMANDS "${CMAKE_SOURCE_DIR}/build/compile_commands.json")
if(NOT CMAKE_BINARY_DIR STREQUAL "${CMAKE_SOURCE_DIR}/build")
  file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/build")
  file(REMOVE "${PROJECT_COMPILE_COMMANDS}")
  file(
    CREATE_LINK
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${PROJECT_COMPILE_COMMANDS}"
    SYMBOLIC
    RESULT PROJECT_COMPILE_COMMANDS_LINK_RESULT
  )

  if(NOT PROJECT_COMPILE_COMMANDS_LINK_RESULT STREQUAL "0")
    add_custom_target(
      project_compile_commands ALL
      COMMAND
        "${CMAKE_COMMAND}" -E copy_if_different
        "${CMAKE_BINARY_DIR}/compile_commands.json"
        "${PROJECT_COMPILE_COMMANDS}"
      COMMENT "Copying compile_commands.json to ${PROJECT_COMPILE_COMMANDS}"
      VERBATIM
    )
  endif()
endif()

set(CMAKE_CXX_STANDARD 20 CACHE STRING "C++ standard (14, 17, 20, or 23)")
set_property(CACHE CMAKE_CXX_STANDARD PROPERTY STRINGS 14 17 20 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

option(PROJECT_ENABLE_TESTING "Build tests with GoogleTest" ON)
option(PROJECT_ENABLE_BENCHMARKS "Build benchmarks with Google Benchmark" OFF)
option(PROJECT_ENABLE_SPDLOG "Use spdlog in the example application" ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(ProjectOptions)
include(Dependencies)

add_subdirectory(libs/core)
add_subdirectory(app)

if(PROJECT_ENABLE_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif()

if(PROJECT_ENABLE_BENCHMARKS)
  add_subdirectory(benchmarks)
endif()
