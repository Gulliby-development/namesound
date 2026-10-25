# frozen_string_literal: true

module Namesound
  module Algo
    module MatchRating
      def self.key(word)
        return "" if word.empty?

        first = word[0]
        codex = +first
        previous = first

        word[1..].each_char do |letter|
          next if "AEIOU".include?(letter)
          next if letter == previous

          codex << letter
          previous = letter
        end

        codex.length > 6 ? codex[0, 3] + codex[-3, 3] : codex
      end
    end
  end
end
