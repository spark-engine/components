module Minitest
  def self.plugin_benchmark_options(opts, options)
    opts.on "--benchmark", "Only run Benchmarks and Memory Profiling" do
      options[:benchmark] = true
    end
    opts.on "--memory-profiler", "Only run Benchmarks and Memory Profiling" do
      options[:memory_profile] = true
    end
  end

  def self.plugin_benchmark_init(options)
    if options[:benchmark]
      options[:filter] = "/^bench_*/"
    else
      options[:filter] = "/^(?!^bench_|.*Benchmark.*)/"
    end
  end
end
