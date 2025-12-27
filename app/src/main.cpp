#include <corelib/simple.hpp>
#include <spdlog/spdlog.h>
int main()
{
    spdlog::info("sum is {:.2f}", corelib::add(1.2, 43.3));
    return 0;
}