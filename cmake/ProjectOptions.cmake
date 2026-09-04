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

  if(CMAKE_CXX_STANDARD EQUAL 14 AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # GoogleTest 1.16 uses portable attribute detection that Clang reports as
    # a C++17 extension in C++14 mode.
    target_compile_options(
      project_warnings INTERFACE -Wno-c++17-attribute-extensions
    )
  endif()
endif()
