#!/usr/bin/env bash

set -Eeuo pipefail

readonly DEFAULT_REPOSITORY="https://github.com/Jw-23/cmake-template.git"

fail() {
  printf '错误: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*"
}

has_tty() {
  [[ -r /dev/tty && -w /dev/tty ]]
}

prompt_value() {
  local variable_name="$1"
  local prompt_text="$2"
  local default_value="$3"
  local current_value="${!variable_name:-}"

  if [[ -n "$current_value" ]]; then
    return
  fi

  has_tty || fail "非交互环境中缺少 ${variable_name}，请通过环境变量提供。"
  printf '%s [%s]: ' "$prompt_text" "$default_value" > /dev/tty
  IFS= read -r current_value < /dev/tty || fail "无法读取输入。"
  printf -v "$variable_name" '%s' "${current_value:-$default_value}"
}

normalize_boolean() {
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    y|yes|true|1|on|是)
      printf 'ON'
      ;;
    n|no|false|0|off|否)
      printf 'OFF'
      ;;
    *)
      return 1
      ;;
  esac
}

prompt_boolean() {
  local variable_name="$1"
  local prompt_text="$2"
  local default_answer="$3"
  local current_value="${!variable_name:-}"
  local hint='y/N'

  if [[ "$default_answer" == 'yes' ]]; then
    hint='Y/n'
  fi

  while true; do
    if [[ -z "$current_value" ]]; then
      has_tty || fail "非交互环境中缺少 ${variable_name}，请通过环境变量提供。"
      printf '%s [%s]: ' "$prompt_text" "$hint" > /dev/tty
      IFS= read -r current_value < /dev/tty || fail "无法读取输入。"
      current_value="${current_value:-$default_answer}"
    fi

    if current_value="$(normalize_boolean "$current_value")"; then
      printf -v "$variable_name" '%s' "$current_value"
      return
    fi

    has_tty || fail "${variable_name} 的值无效，请使用 yes/no。"
    printf '请输入 yes 或 no。\n' > /dev/tty
    current_value=''
  done
}

command -v git >/dev/null 2>&1 || fail '未找到 git，请先安装 Git。'
command -v cmake >/dev/null 2>&1 || fail '未找到 cmake，请先安装 CMake 3.24 或更高版本。'
command -v ninja >/dev/null 2>&1 || fail '未找到 ninja，请先安装 Ninja。'

while true; do
  prompt_value CMAKE_PROJECT_NAME '项目名称' 'my_project'
  if [[ "$CMAKE_PROJECT_NAME" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]]; then
    break
  fi
  has_tty || fail 'CMAKE_PROJECT_NAME 必须以字母开头，且只能包含字母、数字、_ 和 -。'
  printf '项目名称必须以字母开头，且只能包含字母、数字、_ 和 -。\n' > /dev/tty
  CMAKE_PROJECT_NAME=''
done

prompt_value CMAKE_PROJECT_DIR '项目创建目录' "./${CMAKE_PROJECT_NAME}"

while true; do
  prompt_value CMAKE_CPP_STANDARD 'C++ 标准（14/17/20/23）' '20'
  case "$CMAKE_CPP_STANDARD" in
    14|17|20|23)
      break
      ;;
    *)
      has_tty || fail 'CMAKE_CPP_STANDARD 只支持 14、17、20 或 23。'
      printf '请选择 14、17、20 或 23。\n' > /dev/tty
      CMAKE_CPP_STANDARD=''
      ;;
  esac
done

prompt_boolean CMAKE_ENABLE_GTEST '是否引入 Google Test？' 'yes'
prompt_boolean CMAKE_ENABLE_BENCHMARK '是否引入 Google Benchmark？' 'no'
prompt_boolean CMAKE_ENABLE_SPDLOG '是否引入 spdlog？' 'yes'
prompt_boolean CMAKE_ENABLE_FMT '是否引入 fmt？' 'no'
prompt_boolean CMAKE_ENABLE_EIGEN '是否引入 Eigen？' 'no'

if [[ -e "$CMAKE_PROJECT_DIR" ]]; then
  [[ -d "$CMAKE_PROJECT_DIR" ]] || fail "目标路径已存在且不是目录: ${CMAKE_PROJECT_DIR}"
  [[ -z "$(find "$CMAKE_PROJECT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]] || \
    fail "目标目录不是空目录: ${CMAKE_PROJECT_DIR}"
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/cmake-template.XXXXXX")"
template_dir="${work_dir}/template"
trap 'rm -rf "$work_dir"' EXIT

if [[ -n "${CMAKE_TEMPLATE_SOURCE_DIR:-}" ]]; then
  [[ -f "${CMAKE_TEMPLATE_SOURCE_DIR}/CMakeLists.txt" ]] || \
    fail "本地模板目录无效: ${CMAKE_TEMPLATE_SOURCE_DIR}"
  note "正在读取本地模板 ${CMAKE_TEMPLATE_SOURCE_DIR} ..."
  mkdir -p "$template_dir"
  cp -R "${CMAKE_TEMPLATE_SOURCE_DIR}/." "$template_dir/"
else
  repository="${CMAKE_TEMPLATE_REPOSITORY:-$DEFAULT_REPOSITORY}"
  template_ref="${CMAKE_TEMPLATE_REF:-main}"
  note "正在从 ${repository} 拉取模板（${template_ref}）..."
  git clone --quiet --depth 1 --branch "$template_ref" "$repository" "$template_dir" || \
    fail '模板拉取失败，请检查网络、仓库地址或分支名称。'
fi

# Only remove known paths inside the mktemp-created copy.
rm -rf \
  "$template_dir/.git" \
  "$template_dir/.idea" \
  "$template_dir/.vscode" \
  "$template_dir/.cache" \
  "$template_dir/build"
rm -f "$template_dir/.DS_Store" "$template_dir/app/.DS_Store"

mkdir -p "$CMAKE_PROJECT_DIR"
cp -R "$template_dir/." "$CMAKE_PROJECT_DIR/"

cmake_file="${CMAKE_PROJECT_DIR}/CMakeLists.txt"
sed -i.bak \
  -e "s/set(CMAKE_TEMPLATE_PROJECT_NAME \"cmake_template\")/set(CMAKE_TEMPLATE_PROJECT_NAME \"${CMAKE_PROJECT_NAME}\")/" \
  -e "s/set(CMAKE_CXX_STANDARD 20 CACHE STRING/set(CMAKE_CXX_STANDARD ${CMAKE_CPP_STANDARD} CACHE STRING/" \
  -e "s/option(PROJECT_ENABLE_TESTING \"Build tests with GoogleTest\" ON)/option(PROJECT_ENABLE_TESTING \"Build tests with GoogleTest\" ${CMAKE_ENABLE_GTEST})/" \
  -e "s/option(PROJECT_ENABLE_BENCHMARKS \"Build benchmarks with Google Benchmark\" OFF)/option(PROJECT_ENABLE_BENCHMARKS \"Build benchmarks with Google Benchmark\" ${CMAKE_ENABLE_BENCHMARK})/" \
  -e "s/option(PROJECT_ENABLE_SPDLOG \"Use spdlog in the example application\" ON)/option(PROJECT_ENABLE_SPDLOG \"Use spdlog in the example application\" ${CMAKE_ENABLE_SPDLOG})/" \
  -e "s/option(PROJECT_ENABLE_FMT \"Use fmt in the example application\" OFF)/option(PROJECT_ENABLE_FMT \"Use fmt in the example application\" ${CMAKE_ENABLE_FMT})/" \
  -e "s/option(PROJECT_ENABLE_EIGEN \"Use Eigen in the example application\" OFF)/option(PROJECT_ENABLE_EIGEN \"Use Eigen in the example application\" ${CMAKE_ENABLE_EIGEN})/" \
  "$cmake_file"
rm -f "${cmake_file}.bak"

sed \
  -e "s/@PROJECT_NAME@/${CMAKE_PROJECT_NAME}/g" \
  -e "s/@CPP_STANDARD@/${CMAKE_CPP_STANDARD}/g" \
  -e "s/@GTEST_ENABLED@/${CMAKE_ENABLE_GTEST}/g" \
  -e "s/@BENCHMARK_ENABLED@/${CMAKE_ENABLE_BENCHMARK}/g" \
  -e "s/@SPDLOG_ENABLED@/${CMAKE_ENABLE_SPDLOG}/g" \
  -e "s/@FMT_ENABLED@/${CMAKE_ENABLE_FMT}/g" \
  -e "s/@EIGEN_ENABLED@/${CMAKE_ENABLE_EIGEN}/g" \
  "${CMAKE_PROJECT_DIR}/README.project.md.in" > "${CMAKE_PROJECT_DIR}/README.md"

rm -f \
  "${CMAKE_PROJECT_DIR}/README.project.md.in" \
  "${CMAKE_PROJECT_DIR}/install.sh"

note '正在配置 Debug 构建并生成 build/compile_commands.json ...'
if ! cmake -S "$CMAKE_PROJECT_DIR" --preset debug; then
  fail "CMake 配置失败。项目文件已保留在 ${CMAKE_PROJECT_DIR}，请检查上方错误。"
fi

if git -C "$CMAKE_PROJECT_DIR" init --initial-branch=main --quiet 2>/dev/null; then
  :
else
  git -C "$CMAKE_PROJECT_DIR" init --quiet
  git -C "$CMAKE_PROJECT_DIR" symbolic-ref HEAD refs/heads/main
fi

git -C "$CMAKE_PROJECT_DIR" add --all

if [[ -n "$(git -C "$CMAKE_PROJECT_DIR" config user.name || true)" && \
      -n "$(git -C "$CMAKE_PROJECT_DIR" config user.email || true)" ]]; then
  if git -C "$CMAKE_PROJECT_DIR" -c commit.gpgsign=false commit --quiet -m 'chore: initialize project'; then
    commit_status='已创建初始提交'
  else
    commit_status='Git 已初始化且文件已暂存，但初始提交失败'
  fi
else
  commit_status='Git 已初始化且文件已暂存；配置 user.name 和 user.email 后即可提交'
fi

note ''
note "项目 ${CMAKE_PROJECT_NAME} 创建完成：${CMAKE_PROJECT_DIR}"
note "C++${CMAKE_CPP_STANDARD} | Google Test ${CMAKE_ENABLE_GTEST} | Benchmark ${CMAKE_ENABLE_BENCHMARK} | spdlog ${CMAKE_ENABLE_SPDLOG} | fmt ${CMAKE_ENABLE_FMT} | Eigen ${CMAKE_ENABLE_EIGEN}"
note "$commit_status"
note ''
note '下一步：'
note "  cd ${CMAKE_PROJECT_DIR}"
note '  cmake --build --preset debug'
