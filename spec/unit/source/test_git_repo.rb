require 'spec_helper'
module Autotimesheet
  module Source
    describe GitRepo do

      let(:src) {
        GitRepo.new(Path.backfind(".[Gemfile]"))
      }

      it 'works as expected' do
        n = 0
        src.each do |tuple|
          expect(tuple[:end]).to be_a(Time)
          expect(tuple[:start]).to be_nil
          n += 1
        end
        expect(n).to eql(1)
      end

      it 'does not yield anything from the past' do
        n = 0
        src.each(Date.parse("2019-05-01"), Date.parse("2019-05-10")) do |tuple|
          n += 1
        end
        expect(n).to eql(0)
      end

      it 'does not generate yield anything from long future' do
        n = 0
        src.each(Date.parse("2029-05-01"), Date.parse("2029-05-10")) do |tuple|
          n += 1
        end
        expect(n).to eql(0)
      end

    end
  end # module SOurce
end # module Autotimesheet