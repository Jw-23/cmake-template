#include <corelib/simple.hpp>
#include <gtest/gtest.h>
#include <optional>


TEST(MathTest, AddPositiveNumver)
{
    std::optional value(3);
    
    EXPECT_EQ(corelib::add(3, 4), 7);
}