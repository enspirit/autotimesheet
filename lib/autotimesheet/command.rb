module Autotimesheet
  class Command

    def run(argv)
      source = Source::GitRepo.new(argv[0] || ".")
      model = TimingModel.new(min_duration: 15)
      agg = Aggregator.new(model)
      interval = agg.to_multi_interval(source.each)
      puts interval.to_a.join("\n")
      puts
      puts interval.total_duration(0.0)/60.0/60.0
    end

  end # class Command
end # module Autotimesheet