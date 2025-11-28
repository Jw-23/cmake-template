#include <iostream>
#include <corelib/simple.h>
#include <spdlog/spdlog.h>
int main()
{
    spdlog::info("sum is {}", corelib::add(1, 43));
    return 0;
}