# B-样条曲线实现

在 `app/src/main.cpp` 给出了测试代码

```cpp
#include <iostream>
#include <vector>
#include <cmath>
#include <Eigen/Dense>
#include <simple.h>

using Vector2 = Eigen::Vector2d;
using MatrixX = Eigen::MatrixXd;
using VectorX = Eigen::VectorXd;
int main() {
    // 1. 准备数据点 (比如一个简单的正弦波形状)
    std::vector<Vector2> dataPoints;
    dataPoints.push_back(Vector2(0.0, 0.0));
    dataPoints.push_back(Vector2(1.0, 2.0)); // 波峰
    dataPoints.push_back(Vector2(3.0, 2.0)); 
    dataPoints.push_back(Vector2(4.0, 0.0));
    dataPoints.push_back(Vector2(5.0, -2.0)); // 波谷
    dataPoints.push_back(Vector2(6.0, 0.0));

    // 2. 创建插值器 (3次 B-样条)
    geometry::BSplineInterpolator spline(3);
    
    // 3. 执行插值计算
    spline.fit(dataPoints);

    // 4. 输出计算出的控制点
    std::cout << "\n--- Computed Control Points ---" << std::endl;
    const auto& cps = spline.getControlPoints();
    for (size_t i = 0; i < cps.size(); ++i) {
        std::cout << "P" << i << ": (" << cps[i].x() << ", " << cps[i].y() << ")" << std::endl;
    }

    // 5. 验证插值效果
    std::cout << "\n--- Sample Curve Points ---" << std::endl;
    for (int i = 0; i <= 20; ++i) {
        double u = i / 20.0;
        Vector2 p = spline.evaluate(u);
        std::cout << "u=" << u << " -> (" << p.x() << ", " << p.y() << ")" << std::endl;
    }

    return 0;
}
```