require 'spec_helper'
module Autotimesheet
  describe MultiInterval do

    describe "add" do

      it 'keep non overlapping ranges unmerged' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T13:00:00"))
        mi = mi.add(Time.parse("2018-01-01T15:00:00")...Time.parse("2018-01-01T19:00:00"))
        expect(mi.to_a.size).to eql(2)
      end

      it 'merges touching ranges' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T13:00:00"))
        mi = mi.add(Time.parse("2018-01-01T13:00:00")...Time.parse("2018-01-01T19:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T19:00:00"))
      end

      it 'merges overlapping ranges' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T13:00:00"))
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T19:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T19:00:00"))
      end

      it 'strips contained intervals' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T13:00:00"))
        mi = mi.add(Time.parse("2018-01-01T02:00:00")...Time.parse("2018-01-01T05:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T13:00:00"))
      end

      it 'strips empty intervals' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T00:00:00"))
        mi = mi.add(Time.parse("2018-01-02T00:00:00")...Time.parse("2018-01-01T00:00:00"))
        expect(mi.to_a.size).to eql(0)
      end

    end

    describe "sub" do

      it 'ignores uncontained future ranges' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.sub(Time.parse("2018-01-03T00:00:00")...Time.parse("2018-01-03T12:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T12:00:00"))
      end

      it 'ignores uncontained past ranges' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-02T08:00:00")...Time.parse("2018-01-02T18:00:00"))
        mi = mi.sub(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T18:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-02T08:00:00")...Time.parse("2018-01-02T18:00:00"))
      end

      it 'splits when left term contains right term' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.sub(Time.parse("2018-01-01T02:00:00")...Time.parse("2018-01-01T10:00:00"))
        expect(mi.to_a.size).to eql(2)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T02:00:00"))
        expect(mi.to_a[1]).to eql(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
      end

      it 'results in empty when right term contains left term' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T02:00:00")...Time.parse("2018-01-01T10:00:00"))
        mi = mi.sub(Time.parse("2018-01-01T00:00:00")...Time.parse("2018-01-01T12:00:00"))
        expect(mi.to_a.size).to eql(0)
      end

      it 'reduces existing ranges by the right' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.sub(Time.parse("2018-01-01T08:00:00")...Time.parse("2018-01-01T11:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T11:00:00")...Time.parse("2018-01-01T12:00:00"))
      end

      it 'reduces existing ranges by the left' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.sub(Time.parse("2018-01-01T11:00:00")...Time.parse("2018-01-01T14:00:00"))
        expect(mi.to_a.size).to eql(1)
        expect(mi.to_a.first).to eql(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T11:00:00"))
      end

    end

    describe "total_duration" do

      it 'works on an empty interval' do
        mi = MultiInterval.new
        expect(mi.total_duration(0.0)).to eql(0.0)
      end

      it 'works on an singleton' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
        expect(mi.total_duration(0.0)).to eql(2.0 * 60 * 60)
      end

      it 'works on an non singleton with overlaps' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.add(Time.parse("2018-01-01T11:00:00")...Time.parse("2018-01-01T15:00:00"))
        expect(mi.total_duration(0.0)).to eql(5.0 * 60 * 60)
      end

      it 'works on an non singleton with non overlaps' do
        mi = MultiInterval.new
        mi = mi.add(Time.parse("2018-01-01T10:00:00")...Time.parse("2018-01-01T12:00:00"))
        mi = mi.add(Time.parse("2018-01-01T15:00:00")...Time.parse("2018-01-01T18:00:00"))
        expect(mi.total_duration(0.0)).to eql(5.0 * 60 * 60)
      end
    end

  end
end
