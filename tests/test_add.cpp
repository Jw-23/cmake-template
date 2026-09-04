#include <corelib/simple.hpp>
#include <gtest/gtest.h>

TEST(CoreLibTest, AddsTwoNumbers)
{
    EXPECT_DOUBLE_EQ(corelib::add(3.0, 4.0), 7.0);
}
