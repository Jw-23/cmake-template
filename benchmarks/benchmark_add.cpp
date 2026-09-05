#include <benchmark/benchmark.h>
#include <corelib/simple.hpp>

static void benchmark_add(benchmark::State& state)
{
    for (auto _ : state)
    {
        benchmark::DoNotOptimize(corelib::add(1.2, 43.3));
    }
}

// Google Benchmark registers benchmarks through an internal global object.
BENCHMARK(benchmark_add);  // NOLINT(cppcoreguidelines-avoid-non-const-global-variables,cppcoreguidelines-owning-memory)
