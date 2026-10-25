# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/inputs"
require_relative "../data/algorithms"
require_relative "../key/keyer"
require_relative "../report/key_report"
require_relative "../base/text"

module Namesound
  module KeyCommand
    def self.run(args, flags, _values, inputs)
      raise Failure, "missing ALGORITHM" if args.empty?
      raise Failure, "missing FILE" if args.length == 1
      raise Failure, "too many arguments" if args.length > 2

      algorithm = Algorithms.find(args[0])
      raise Failure, "unknown algorithm #{Text.show(args[0])}" unless algorithm

      entries = Inputs.entries(inputs.read(args[1]).text)
      keys = entries.map { |entry| Keyer.key(algorithm.name, entry) }
      KeyReport.render(entries, keys, flags.include?("--bare"))
    end
  end
end
