# frozen_string_literal: true

require_relative "../base/grid"
require_relative "../base/output"
require_relative "../base/text"

module Namesound
  module KeyReport
    def self.render(entries, keys, bare)
      code = keys.any?(&:empty?) ? 1 : 0

      if bare
        output = +""
        keys.each { |key| output << key << "\n" }
      elsif entries.empty?
        output = +""
      else
        rows = [%w[NAME KEY]]
        entries.each_with_index do |entry, index|
          key = keys[index]
          rows << [Text.plain(entry), key.empty? ? "-" : key]
        end
        output = Grid.render(rows)
      end

      Output.new(output, entries.empty? ? 0 : code)
    end
  end
end
