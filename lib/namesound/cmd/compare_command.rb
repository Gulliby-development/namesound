# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/text"
require_relative "../data/algorithms"
require_relative "../key/keyer"
require_relative "../match/similar"
require_relative "../report/compare_report"

module Namesound
  module CompareCommand
    def self.run(args, _flags, values, _inputs)
      raise Failure, "missing NAME" if args.length < 2
      raise Failure, "too many arguments" if args.length > 2

      selected_name = values["--algorithm"]
      algorithms = if selected_name
                     algorithm = Algorithms.find(selected_name)
                     raise Failure, "unknown algorithm #{Text.show(selected_name)}" unless algorithm

                     [algorithm]
                   else
                     Algorithms.all
                   end

      rows = algorithms.map do |algorithm|
        first_key = Keyer.key(algorithm.name, args[0])
        second_key = Keyer.key(algorithm.name, args[1])
        same = Similar.same?(algorithm.name, args[0], args[1])
        CompareReport::Row.new(algorithm.name, first_key, second_key, same)
      end

      CompareReport.render(rows)
    end
  end
end
