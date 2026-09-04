#include <benchmark/benchmark.h>
#include <corelib/simple.hpp>

static void benchmark_add(benchmark::State& state)
{
    for (auto _ : state)
    {
        benchmark::DoNotOptimize(corelib::add(1.2, 43.3));
    }
}

BENCHMARK(benchmark_add);
