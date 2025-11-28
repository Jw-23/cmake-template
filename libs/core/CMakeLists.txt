
add_library(CoreLib SHARED src/simple.cpp)

target_include_directories(CoreLib PUBLIC include)


add_library(Math::Core ALIAS CoreLib)