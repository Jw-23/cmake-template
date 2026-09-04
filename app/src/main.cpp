#include <corelib/simple.hpp>

#ifdef PROJECT_HAS_EIGEN
#include <Eigen/Core>
#endif

#ifdef PROJECT_HAS_FMT
#include <fmt/format.h>
#endif

#ifdef PROJECT_HAS_SPDLOG
#include <spdlog/spdlog.h>
#elif !defined(PROJECT_HAS_FMT)
#include <iostream>
#endif

auto main() -> int
{
    constexpr double lhs = 1.2;
    constexpr double rhs = 43.3;

#ifdef PROJECT_HAS_EIGEN
    Eigen::Vector2d values;
    values << lhs, rhs;
    const auto result = values.sum();
#else
    const auto result = corelib::add(lhs, rhs);
#endif

#ifdef PROJECT_HAS_SPDLOG
    spdlog::info("sum is {:.2f}", result);
#elif defined(PROJECT_HAS_FMT)
    fmt::print("sum is {:.2f}\n", result);
#else
    std::cout << "sum is " << result << '\n';
#endif

    return 0;
}
