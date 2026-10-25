# frozen_string_literal: true

require_relative "../base/grid"
require_relative "../base/output"
require_relative "../base/text"

module Namesound
  module GroupReport
    def self.render(groups)
      rows = groups.empty? ? [] : [%w[KEY COUNT NAMES]]
      name_count = 0

      groups.each do |group|
        names = group.names.map { |name| Text.plain(name) }
        name_count += names.length
        rows << [group.key, names.length.to_s, names.join(", ")]
      end

      output = Grid.render(rows)
      output << "#{Text.plural(groups.length, "group")}, #{Text.plural(name_count, "name")}\n"
      Output.new(output, groups.empty? ? 1 : 0)
    end
  end
end
