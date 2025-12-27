
add_library(CoreLib SHARED src/simple.cpp)

target_include_directories(CoreLib PUBLIC include)


add_library(Math::Core ALIAS CoreLib)

add_executable(corelibtests tests/test_add.cpp)

target_link_libraries(corelibtests PRIVATE GTest::gtest_main Math::Core)

include(GoogleTest)
gtest_discover_tests(corelibtests)
