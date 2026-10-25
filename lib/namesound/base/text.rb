# frozen_string_literal: true

module Namesound
  module Text
    def self.plain(text)
      result = +""
      text.each_char do |character|
        codepoint = character.ord
        result << (codepoint.between?(0x20, 0x7E) ? character : "?")
      end
      result
    end

    def self.show(text)
      "\"#{plain(text)}\""
    end

    def self.plural(count, word)
      "#{count} #{word}#{"s" unless count == 1}"
    end

    def self.fold_ascii(text)
      result = +""
      text.each_char do |character|
        codepoint = character.ord
        result << (codepoint.between?(0x41, 0x5A) ? (codepoint + 0x20).chr : character)
      end
      result
    end
  end
end
