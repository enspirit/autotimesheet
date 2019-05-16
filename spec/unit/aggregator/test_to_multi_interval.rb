require 'spec_helper'

module Autotimesheet
  describe Aggregator, "to_multi_interval" do

    let(:_8H) {
      Time.parse("2019-05-15T08:00:00")
    }

    let(:_8H10) {
      Time.parse("2019-05-15T08:10:00")
    }

    let(:_8H25) {
      Time.parse("2019-05-15T08:25:00")
    }

    let(:_8H40) {
      Time.parse("2019-05-15T08:40:00")
    }

    let(:model) {
      TimingModel.new(min_duration: 15)
    }

    let(:aggregator) {
      Aggregator.new(model)
    }

    it 'works as expected' do
      tuples = [
        { start: _8H,   end: _8H25 },
        { start: _8H10, end: _8H40 }
      ]
      got = aggregator.to_multi_interval(tuples)
      expect(got.total_duration(0)).to eql(40.0 * 60)
    end

  end # class Aggregator
end # module Autotimesheet
