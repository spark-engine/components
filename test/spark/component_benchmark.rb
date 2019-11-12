# frozen_string_literal: true

require "test_helper"

require "spark/component"
require "minitest/benchmark"
require "memory_profiler"

module Spark
  class ComponentBenchmarkTest < Minitest::Benchmark
    include ActionView::Component::TestHelpers

    # Override self.bench_range or default range is [1, 10, 100, 1_000, 10_000]
    def bench_test_component
      assert_performance_linear 0.9999 do |n| # n is a range value
        n.times { render_inline(SimpleComponent) }
      end
    end

    def bench_memory_profiler
      puts MemoryProfiler.report(allow_files: "components/lib/spark") do
        1_000.times { render_inline(SimpleComponent) }
      end.pretty_print
    end
  end
end
