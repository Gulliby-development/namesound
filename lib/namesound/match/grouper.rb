# frozen_string_literal: true

require_relative "../key/keyer"

module Namesound
  module Grouper
    Group = Struct.new(:key, :names)

    def self.group(algorithm, entries, minimum, order = "key")
      seen_entries = {}
      groups_by_key = {}

      entries.each do |entry|
        next if seen_entries.key?(entry)

        seen_entries[entry] = true
        key = Keyer.key(algorithm, entry)
        next if key.empty?

        group = groups_by_key[key]
        unless group
          group = Group.new(key, [])
          groups_by_key[key] = group
        end
        group.names << entry
      end

      groups = groups_by_key.values.select { |group| group.names.length >= minimum }
      return groups.sort_by { |group| [-group.names.length, group.key] } if order == "count"

      groups.sort_by(&:key)
    end
  end
end
