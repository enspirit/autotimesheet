module Autotimesheet
  class Aggregator

    def initialize(model)
      @model = model
    end
    attr_reader :model

    def to_multi_interval(tuples)
      tuples.inject(MultiInterval.new){|mi,t|
        mi + to_work_interval(t)
      }
    end

    def to_work_interval(tuple)
      start_end = if tuple[:start] && tuple[:end]
        { start: tuple[:start], end: tuple[:end] }
      elsif tuple[:start]
        { start: tuple[:start], end: tuple[:start] + model.min_duration(tuple)*60 }
      elsif tuple[:end]
        { start: tuple[:end] - model.min_duration(tuple)*60, end: tuple[:end] }
      end
      start_end[:start]...start_end[:end]
    end

  end # class Aggregator
end # module Autotimesheet
