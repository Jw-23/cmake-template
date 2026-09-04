add_executable(project_tests test_add.cpp)
set_target_properties(project_tests PROPERTIES OUTPUT_NAME "${PROJECT_NAME}_tests")
target_link_libraries(
  project_tests
  PRIVATE GTest::gtest_main project_core project_options project_warnings
)

include(GoogleTest)
gtest_discover_tests(project_tests)
