# frozen_string_literal: true

require_relative "../base/text"

module Namesound
  module Algorithms
    Entry = Struct.new(:name, :key_length, :about)

    ENTRIES = [
      Entry.new("soundex", "4 chars", "American Soundex").freeze,
      Entry.new("refined", "any length", "Refined Soundex").freeze,
      Entry.new("nysiis", "6 chars", "NYSIIS, cut at 6").freeze,
      Entry.new("metaphone", "any length", "original Metaphone").freeze,
      Entry.new("cologne", "digits", "Cologne phonetics (German)").freeze,
      Entry.new("mra", "6 chars", "Match Rating Approach codex").freeze
    ].freeze

    def self.all
      ENTRIES.dup
    end

    def self.find(name)
      folded_name = Text.fold_ascii(name)
      ENTRIES.find { |entry| entry.name == folded_name }
    end
  end
end
