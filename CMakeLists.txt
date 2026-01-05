cmake_minimum_required(VERSION 4.0.2)

project(MathUtil VERSION 1.0 LANGUAGES CXX)



# 自动生成compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    # 定义目标路径：项目根目录下的 build 文件夹
    set(EXPORT_DIR "${CMAKE_SOURCE_DIR}/build")

    # 只有当源文件存在时才拷贝 (防止第一次配置时报错)
    if(EXISTS "${CMAKE_BINARY_DIR}/compile_commands.json")
        message(STATUS "Copying compile_commands.json to ${EXPORT_DIR}")
        file(COPY "${CMAKE_BINARY_DIR}/compile_commands.json" DESTINATION "${EXPORT_DIR}")
    endif()
endif()
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
# file(DOWNLOAD 
#      https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.42.0/CPM.cmake 
#      "${CMAKE_CURRENT_SOURCE_DIR}/CPM.cmake"
# )



include("${CMAKE_CURRENT_SOURCE_DIR}/CPM.cmake")
CPMAddPackage("gh:google/googletest@1.17.0")
# 开启测试
enable_testing()
add_subdirectory(libs/core)

add_subdirectory(app)

