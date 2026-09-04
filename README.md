# CMake C++ 项目模板

一个可交互初始化的现代 C++ 模板。依赖由 CPM.cmake 管理，Google Test、
Google Benchmark 和 spdlog 都可以按项目选择。

## 一条命令创建项目

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jw-23/cmake-template/main/install.sh)
```

脚本会依次询问：

- 项目名称和创建目录；
- C++ 标准（14、17、20 或 23）；
- 是否启用 Google Test；
- 是否启用 Google Benchmark；
- 是否启用 spdlog。

完成后，脚本会清除模板仓库历史，在新目录创建 `main` 分支，暂存全部文件，
并在本机已配置 Git 用户名和邮箱时创建初始提交。

## 无交互用法

所有问题都能通过环境变量预先回答，适合脚本或 CI：

```bash
CMAKE_PROJECT_NAME=my_app \
CMAKE_PROJECT_DIR=./my_app \
CMAKE_CPP_STANDARD=23 \
CMAKE_ENABLE_GTEST=yes \
CMAKE_ENABLE_BENCHMARK=no \
CMAKE_ENABLE_SPDLOG=yes \
bash <(curl -fsSL https://raw.githubusercontent.com/Jw-23/cmake-template/main/install.sh)
```

可用的高级变量：

- `CMAKE_TEMPLATE_REPOSITORY`：模板 Git 地址；
- `CMAKE_TEMPLATE_REF`：分支或标签，默认为 `main`；
- `CMAKE_TEMPLATE_SOURCE_DIR`：直接使用本地模板目录，主要用于开发与离线测试。

## 直接使用模板

仓库本身也是一个有效项目，默认使用 C++20，并启用 Google Test 和 spdlog：

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

可用的 CMake 选项：

| 选项 | 默认值 | 说明 |
| --- | --- | --- |
| `PROJECT_ENABLE_TESTING` | `ON` | 构建 Google Test 测试 |
| `PROJECT_ENABLE_BENCHMARKS` | `OFF` | 构建 Google Benchmark 基准测试 |
| `PROJECT_ENABLE_SPDLOG` | `ON` | 示例程序使用 spdlog |
