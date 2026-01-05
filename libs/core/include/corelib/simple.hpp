#pragma once

namespace corelib
{
    // 这是一个双参数概念：检查 T1 和 T2 是否能相加
    template <typename T1, typename T2 = T1>
    concept HAdd = requires(T1 lhs, T2 rhs) {
        // 这里不限制返回类型必须是 T1，只要能算就行
        // 或者可以用 std::common_type_t<T1, T2> 来约束
        lhs + rhs;
    };

    // 注意：这里不能用 HAdd auto a，因为那只能约束单个类型
    // 我们必须用 requires 联合约束两个参数
    auto add(auto num1, auto num2)
        requires HAdd<decltype(num1), decltype(num2)>
    {
        return num1 + num2;
    }
}