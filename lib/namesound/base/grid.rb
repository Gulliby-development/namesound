# frozen_string_literal: true

module Namesound
  module Grid
    def self.render(rows)
      return +"" if rows.empty?

      widths = Array.new(rows.first.length, 0)
      rows.each do |row|
        row.each_with_index do |cell, index|
          widths[index] = [widths[index], cell.length].max
        end
      end

      output = +""
      rows.each do |row|
        row.each_with_index do |cell, index|
          output << "  " unless index.zero?
          output << cell
          output << (" " * (widths[index] - cell.length)) unless index == row.length - 1
        end
        output << "\n"
      end
      output
    end
  end
end
