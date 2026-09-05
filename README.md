# CMake C++ Project Template

An interactive modern C++ project template powered by CMake and CPM.cmake.
GoogleTest, Google Benchmark, spdlog, fmt, and Eigen are optional.

## Create a project

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Jw-23/cmake-template/main/install.sh)
```

The installer asks for:

- the project name and destination directory;
- the C++ standard: 14, 17, 20, or 23;
- whether to enable GoogleTest;
- whether to enable Google Benchmark;
- whether to enable spdlog;
- whether to enable fmt;
- whether to enable Eigen.

It then configures a Debug build, generates `build/compile_commands.json`,
removes the template repository history, initializes a new `main` branch, and
stages all generated files. If Git user identity is configured, it also creates
the initial commit.

## Non-interactive usage

Every prompt can be supplied through environment variables:

```bash
CMAKE_PROJECT_NAME=my_app \
CMAKE_PROJECT_DIR=./my_app \
CMAKE_CPP_STANDARD=14 \
CMAKE_ENABLE_GTEST=yes \
CMAKE_ENABLE_BENCHMARK=yes \
CMAKE_ENABLE_SPDLOG=yes \
CMAKE_ENABLE_FMT=no \
CMAKE_ENABLE_EIGEN=yes \
bash <(curl -fsSL https://raw.githubusercontent.com/Jw-23/cmake-template/main/install.sh)
```

Advanced environment variables:

- `CMAKE_TEMPLATE_REPOSITORY`: template Git URL;
- `CMAKE_TEMPLATE_REF`: branch or tag, defaults to `main`;
- `CMAKE_TEMPLATE_SOURCE_DIR`: local template directory for development or
  offline testing.

## Use the repository directly

The repository is a valid project by itself. It defaults to C++20 with
GoogleTest and spdlog enabled:

```bash
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
```

Available CMake options:

| Option | Default | Description |
| --- | --- | --- |
| `PROJECT_ENABLE_TESTING` | `ON` | Build the GoogleTest test suite |
| `PROJECT_ENABLE_BENCHMARKS` | `OFF` | Build Google Benchmark targets |
| `PROJECT_ENABLE_SPDLOG` | `ON` | Use spdlog in the example application |
| `PROJECT_ENABLE_FMT` | `OFF` | Use fmt; share it with spdlog when both are enabled |
| `PROJECT_ENABLE_EIGEN` | `OFF` | Use Eigen in the example application |

## C++ compatibility

Dependency versions are selected so each dependency can itself be built by a
compiler limited to the selected C++ standard.

| C++ standard | GoogleTest | Google Benchmark | spdlog | fmt | Eigen |
| --- | --- | --- | --- | --- | --- |
| C++14 | 1.16.0 | 1.9.0 | 1.17.0 | 12.1.0 | 5.0.1 |
| C++17/20/23 | 1.18.0 | 1.9.5 | 1.17.0 | 12.1.0 | 5.0.1 |
