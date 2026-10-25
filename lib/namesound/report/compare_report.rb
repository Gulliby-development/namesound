# frozen_string_literal: true

require_relative "../base/grid"
require_relative "../base/output"

module Namesound
  module CompareReport
    Row = Struct.new(:algorithm, :first_key, :second_key, :same)

    def self.render(rows)
      table = [%w[ALGORITHM FIRST SECOND SAME]]
      rows.each do |row|
        table << [
          row.algorithm,
          row.first_key.empty? ? "-" : row.first_key,
          row.second_key.empty? ? "-" : row.second_key,
          row.same ? "yes" : "no"
        ]
      end

      agreements = rows.count(&:same)
      output = Grid.render(table) + "agree: #{agreements} of #{rows.length}\n"
      Output.new(output, agreements.positive? ? 0 : 1)
    end
  end
end
