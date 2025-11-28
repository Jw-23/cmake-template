cmake_minimum_required(VERSION 4.0.2)

project(MathUtil VERSION 1.0 LANGUAGES CXX)

include("${CMAKE_CURRENT_SOURCE_DIR}/CPM.cmake")
# 1. 可执行文件 (.exe) 输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# 2. 静态库 (.a / .lib) 输出目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

# 3. 动态库 (.so / .dll) 输出目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

# 强制开启 C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#  更新CPM到最新版本

include("${CMAKE_CURRENT_SOURCE_DIR}/CPM.cmake")

add_subdirectory(libs/core)

add_subdirectory(app)

