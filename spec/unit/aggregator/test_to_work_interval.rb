require 'spec_helper'

module Autotimesheet
  describe Aggregator, "to_work_interval" do

    let(:_8H) {
      Time.parse("2019-05-15T08:00:00")
    }

    let(:_8H10) {
      Time.parse("2019-05-15T08:10:00")
    }

    let(:_8H25) {
      Time.parse("2019-05-15T08:25:00")
    }

    let(:model) {
      TimingModel.new(min_duration: 15)
    }

    let(:aggregator) {
      Aggregator.new(model)
    }

    it 'works as expected when start and end are defined and larger that min duration' do
      tuple = {
        start: _8H,
        end: _8H25
      }
      got = aggregator.to_work_interval(tuple)
      expect(got).to eql(_8H..._8H25)
    end

    it 'works as expected when start is not defined' do
      tuple = {
        start: nil,
        end: _8H25
      }
      got = aggregator.to_work_interval(tuple)
      expect(got).to eql(_8H10..._8H25)
    end

    it 'works as expected when end is not defined' do
      tuple = {
        start: _8H10,
        end: nil
      }
      got = aggregator.to_work_interval(tuple)
      expect(got).to eql(_8H10..._8H25)
    end

  end # class Aggregator
end # module Autotimesheet