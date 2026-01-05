#include <corelib/simple.hpp>
#include <spdlog/spdlog.h>
auto main() -> int
{
    constexpr double num1=1.2;
    constexpr double num2=43.3;
    spdlog::info("sum is {:.2f}", corelib::add(num1, num2));
    return 0;
}