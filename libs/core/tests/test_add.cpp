#include <corelib/simple.hpp>
#include <gtest/gtest.h>

TEST(MathTest, AddPositiveNumver)
{
    EXPECT_EQ(corelib::add(3, 4), 7);
}