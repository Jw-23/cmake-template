#include <corelib/simple.hpp>

#ifdef PROJECT_HAS_SPDLOG
#include <spdlog/spdlog.h>
#else
#include <iostream>
#endif

auto main() -> int
{
    constexpr double lhs = 1.2;
    constexpr double rhs = 43.3;
    const auto result = corelib::add(lhs, rhs);

#ifdef PROJECT_HAS_SPDLOG
    spdlog::info("sum is {:.2f}", result);
#else
    std::cout << "sum is " << result << '\n';
#endif

    return 0;
}
