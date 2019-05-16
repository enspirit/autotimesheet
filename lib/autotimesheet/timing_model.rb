module Autotimesheet
  class TimingModel

    def initialize(data)
      @data = data
    end

    def min_duration(tuple)
      @data[:min_duration]
    end

  end # class TimingModel
end # module Autotimesheet
