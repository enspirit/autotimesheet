module Autotimesheet
  class MultiInterval

    def initialize(ranges = [])
      @ranges = ranges
    end

    def plus(range)
      MultiInterval.new(normalize(@ranges + [range]))
    end
    alias :+ :plus
    alias :add :plus

    def minus(x)
      MultiInterval.new(@ranges.map{|y|
        if x.begin >= y.begin && x.end <= y.end
          [ y.begin...x.begin, x.end...y.end ]
        elsif x.begin <= y.begin && x.end <= y.end && x.end >= y.begin
          x.end...y.end
        elsif x.begin <= y.end && x.end >= y.end
          y.begin...x.begin
        else
          y
        end
      }.flatten.reject{|r| r.begin >= r.end })
    end
    alias :- :minus
    alias :sub :minus

    def empty?
      @ranges.empty? || @ranges.all?{|r| r.begin >= r.end }
    end

    def total_duration(empty)
      to_a.inject(empty){|memo,range|
        memo + (range.end - range.begin)
      }
    end

    def to_a
      @ranges.dup
    end

  private

    def normalize(ranges)
      ranges
        .sort{|r1,r2| r1.begin <=> r2.begin }
        .reject{|r| r.begin >= r.end }
        .inject([]) do |rs, r|
          if rs.empty?
            [r]
          elsif rs.last.end >= r.begin
            # INV: rs.last.begin <= r.begin, because of sort
            # INV: rs.last.end >= r.begin, because of if
            # INV: they do overlap
            if rs.last.end >= r.end
              # INV: r is completely contained in rs.last, and can be skipped
              rs
            else
              # INV: r is not contained in rs.last, they can be merged
              rs[0...-1] + [rs.last.begin...r.end]
            end
          else
            # INV: rs.last.begin <= r.begin, because of sort
            # INV: rs.last.end < r.begin, because of else
            # INV: they do not overlap
            rs + [r]
          end
        end
    end

  end # class MultiInterval
end # module Autotimesheet
