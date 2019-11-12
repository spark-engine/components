# frozen_string_literal: true

require "test_helper"
require "action_view/component/test_helpers"

require "rails/test_help"
require "spark/component"
require "minitest/benchmark"
require "memory_profiler"

module Spark
  class ElementBenchmarkTest < Minitest::Benchmark
    include ActionView::Component::TestHelpers

    # Override self.bench_range or default range is [1, 10, 100, 1_000, 10_000]
    def bench_test_component
      assert_performance_linear 0.9999 do |n| # n is a range value
        n.times { render_inline(TestComponent) }
      end
    end

    def bench_memory_profiler
      puts MemoryProfiler.report(allow_files: "components/lib") do
        1_000.times { render_inline(TestComponent) }
      end.pretty_print
    end
  end
end
