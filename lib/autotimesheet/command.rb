module Autotimesheet
  class Command

    def run(argv)
      source = Source::GitRepo.new(argv[0] || ".")

      model = TimingModel.new(min_duration: 60)
      agg = Aggregator.new(model)

      type = Bmg::Type::ANY.with_attrlist([:start, :end, :who])
      base = Bmg::Relation.new(source.each, type)

      require "json"
      details = details(base, model, agg)
      summary = summarize(details)
      puts JSON.pretty_generate(summary)
    end

    def details(base, model, agg)
      rel = base
        .extend(:date => ->(t){
          (t[:start] || t[:end]).to_date
        })
        .group([:start, :end], :crumbs, :array => true)
        .extend(:work_intervals => ->(t){
          agg.to_multi_interval(t[:crumbs])
        })
      rel = duration_per_who(rel)
      rel = amplitude_per_who_and_day(rel)
      rel = rel.allbut([:work_intervals, :crumbs])
      rel
    end

    def summarize(details)
      details
        .extend({
          :lightest_amplitude => ->(t){ t[:amplitude] },
          :heaviest_amplitude => ->(t){ t[:amplitude] },
          :avg_amplitude => ->(t){ t[:amplitude] },
        })
        .summarize([:who], {
          :earliest => :min,
          :latest => :max,
          :total_duration => :sum,
          :avg_amplitude => :avg,
          :lightest_amplitude => :min,
          :heaviest_amplitude => :max,
        })
    end

    def amplitude_per_who_and_day(rel)
      rel.extend({
        :earliest  => ->(t){ t[:work_intervals].begin.strftime("%H:%M") },
        :latest    => ->(t){ t[:work_intervals].end.strftime("%H:%M")   },
        :amplitude => ->(t){ (t[:work_intervals].end - t[:work_intervals].begin) / 60.0 / 60.0 },
      })
    end

    def duration_per_who(rel)
      rel.extend(:total_duration => ->(t){
        t[:work_intervals].total_duration(0.0)/60.0/60.0
      })
    end

  end # class Command
end # module Autotimesheet
