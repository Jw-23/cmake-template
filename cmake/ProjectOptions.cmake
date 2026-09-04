add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE "cxx_std_${CMAKE_CXX_STANDARD}")

add_library(project_warnings INTERFACE)
if(MSVC)
  target_compile_options(project_warnings INTERFACE /W4 /permissive-)
else()
  target_compile_options(
    project_warnings
    INTERFACE -Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion
  )
endif()
