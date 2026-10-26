# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/inputs"
require_relative "../base/text"
require_relative "../data/algorithms"
require_relative "../match/grouper"
require_relative "../report/group_report"

module Namesound
  module GroupCommand
    def self.run(args, _flags, values, inputs)
      raise Failure, "missing ALGORITHM" if args.empty?
      raise Failure, "missing FILE" if args.length == 1

      algorithm = Algorithms.find(args[0])
      raise Failure, "unknown algorithm #{Text.show(args[0])}" unless algorithm

      minimum = values.fetch("--min", "2")
      unless minimum.match?(/\A[1-9][0-9]?\z/)
        raise Failure, "invalid --min #{Text.show(minimum)} (expected 1 to 99)"
      end

      order = values.fetch("--sort", "key")
      unless %w[key count].include?(order)
        raise Failure, "invalid --sort #{Text.show(order)} (expected key or count)"
      end

      entries = args.drop(1).flat_map do |file|
        source = inputs.read(file)
        Inputs.entries(source.text)
      end

      groups = Grouper.group(algorithm.name, entries, minimum.to_i, order)
      GroupReport.render(groups)
    end
  end
end
