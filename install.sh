#!/usr/bin/env bash

set -Eeuo pipefail

readonly DEFAULT_REPOSITORY="https://github.com/Jw-23/cmake-template.git"

fail() {
  printf 'Error: %s\n' "$*" >&2
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

  has_tty || fail "${variable_name} is required in a non-interactive environment."
  printf '%s [%s]: ' "$prompt_text" "$default_value" > /dev/tty
  IFS= read -r current_value < /dev/tty || fail "Unable to read input."
  printf -v "$variable_name" '%s' "${current_value:-$default_value}"
}

normalize_boolean() {
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    y|yes|true|1|on)
      printf 'ON'
      ;;
    n|no|false|0|off)
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
      has_tty || fail "${variable_name} is required in a non-interactive environment."
      printf '%s [%s]: ' "$prompt_text" "$hint" > /dev/tty
      IFS= read -r current_value < /dev/tty || fail "Unable to read input."
      current_value="${current_value:-$default_answer}"
    fi

    if current_value="$(normalize_boolean "$current_value")"; then
      printf -v "$variable_name" '%s' "$current_value"
      return
    fi

    has_tty || fail "${variable_name} is invalid; use yes or no."
    printf 'Please enter yes or no.\n' > /dev/tty
    current_value=''
  done
}

command -v git >/dev/null 2>&1 || fail 'Git is required but was not found.'
command -v cmake >/dev/null 2>&1 || fail 'CMake 3.24 or newer is required but was not found.'
command -v ninja >/dev/null 2>&1 || fail 'Ninja is required but was not found.'

while true; do
  prompt_value CMAKE_PROJECT_NAME 'Project name' 'my_project'
  if [[ "$CMAKE_PROJECT_NAME" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]]; then
    break
  fi
  has_tty || fail 'CMAKE_PROJECT_NAME must start with a letter and contain only letters, digits, underscores, and hyphens.'
  printf 'The project name must start with a letter and contain only letters, digits, underscores, and hyphens.\n' > /dev/tty
  CMAKE_PROJECT_NAME=''
done

prompt_value CMAKE_PROJECT_DIR 'Destination directory' "./${CMAKE_PROJECT_NAME}"

while true; do
  prompt_value CMAKE_CPP_STANDARD 'C++ standard (14/17/20/23)' '20'
  case "$CMAKE_CPP_STANDARD" in
    14|17|20|23)
      break
      ;;
    *)
      has_tty || fail 'CMAKE_CPP_STANDARD must be 14, 17, 20, or 23.'
      printf 'Choose 14, 17, 20, or 23.\n' > /dev/tty
      CMAKE_CPP_STANDARD=''
      ;;
  esac
done

prompt_boolean CMAKE_ENABLE_GTEST 'Enable GoogleTest?' 'yes'
prompt_boolean CMAKE_ENABLE_BENCHMARK 'Enable Google Benchmark?' 'no'
prompt_boolean CMAKE_ENABLE_SPDLOG 'Enable spdlog?' 'yes'
prompt_boolean CMAKE_ENABLE_FMT 'Enable fmt?' 'no'
prompt_boolean CMAKE_ENABLE_EIGEN 'Enable Eigen?' 'no'

if [[ -e "$CMAKE_PROJECT_DIR" ]]; then
  [[ -d "$CMAKE_PROJECT_DIR" ]] || fail "The destination exists and is not a directory: ${CMAKE_PROJECT_DIR}"
  [[ -z "$(find "$CMAKE_PROJECT_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]] || \
    fail "The destination directory is not empty: ${CMAKE_PROJECT_DIR}"
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/cmake-template.XXXXXX")"
template_dir="${work_dir}/template"
trap 'rm -rf "$work_dir"' EXIT

if [[ -n "${CMAKE_TEMPLATE_SOURCE_DIR:-}" ]]; then
  [[ -f "${CMAKE_TEMPLATE_SOURCE_DIR}/CMakeLists.txt" ]] || \
    fail "Invalid local template directory: ${CMAKE_TEMPLATE_SOURCE_DIR}"
  note "Reading the local template from ${CMAKE_TEMPLATE_SOURCE_DIR} ..."
  mkdir -p "$template_dir"
  cp -R "${CMAKE_TEMPLATE_SOURCE_DIR}/." "$template_dir/"
else
  repository="${CMAKE_TEMPLATE_REPOSITORY:-$DEFAULT_REPOSITORY}"
  template_ref="${CMAKE_TEMPLATE_REF:-main}"
  note "Fetching template ${template_ref} from ${repository} ..."
  git clone --quiet --depth 1 --branch "$template_ref" "$repository" "$template_dir" || \
    fail 'Unable to fetch the template. Check the network, repository URL, and ref.'
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

note 'Configuring the Debug build and generating build/compile_commands.json ...'
if ! cmake -S "$CMAKE_PROJECT_DIR" --preset debug; then
  fail "CMake configuration failed. Project files remain in ${CMAKE_PROJECT_DIR}; review the error above."
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
    commit_status='Created the initial commit'
  else
    commit_status='Initialized Git and staged all files, but the initial commit failed'
  fi
else
  commit_status='Initialized Git and staged all files; configure user.name and user.email before committing'
fi

note ''
note "Created ${CMAKE_PROJECT_NAME} in ${CMAKE_PROJECT_DIR}"
note "C++${CMAKE_CPP_STANDARD} | Google Test ${CMAKE_ENABLE_GTEST} | Benchmark ${CMAKE_ENABLE_BENCHMARK} | spdlog ${CMAKE_ENABLE_SPDLOG} | fmt ${CMAKE_ENABLE_FMT} | Eigen ${CMAKE_ENABLE_EIGEN}"
note "$commit_status"
note ''
note 'Next steps:'
note "  cd ${CMAKE_PROJECT_DIR}"
note '  cmake --build --preset debug'
