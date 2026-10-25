# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/grid"
require_relative "../base/output"
require_relative "../data/algorithms"

module Namesound
  module AlgorithmsCommand
    def self.run(args, _flags, _values, _inputs)
      raise Failure, "too many arguments" unless args.empty?

      rows = [%w[NAME KEY ABOUT]]
      Algorithms.all.each do |entry|
        rows << [entry.name, entry.key_length, entry.about]
      end

      Output.new(Grid.render(rows), 0)
    end
  end
end
