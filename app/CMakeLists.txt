
add_executable(app src/main.cpp)


CPMAddPackage("gh:gabime/spdlog#v1.16.0")


target_link_libraries(app PRIVATE Math::Core spdlog::spdlog)
