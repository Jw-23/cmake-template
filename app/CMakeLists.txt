
add_executable(app src/main.cpp)
# file(DOWNLOAD 
#      https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.42.0/CPM.cmake 
#      "${CMAKE_BINARY_DIR}/CPM.cmake"
# )


# include("${CMAKE_CURRENT_SOURCE_DIR}/CPM.cmake")

CPMAddPackage("gh:gabime/spdlog#v1.16.0")


target_link_libraries(app PRIVATE Math::Core spdlog::spdlog)
