require 'rugged'
module Autotimesheet
  module Source
    class GitRepo
      include Source

        def initialize(repo_root)
          @repo_root = repo_root
        end

        def each(from = Date.today - 60, to = Date.today)
          return to_enum(:each, from, to) unless block_given?
          repo = Rugged::Repository.new(@repo_root)
          walker = Rugged::Walker.new(repo)
          walker.sorting(Rugged::SORT_DATE)

          repo.branches.each do |branch|
            walker.push(branch.resolve.target)
          end

          walker.each do |c|
            next unless c.time.to_date >= from && c.time.to_date <= to
            yield({
              who: c.author[:name],
              start: nil,
              end: c.time
            })
          end
        end      

    end # class GitRepo
  end # module Source
end # module Autotimesheet
