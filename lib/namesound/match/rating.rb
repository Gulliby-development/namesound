# frozen_string_literal: true

module Namesound
  module Rating
    def self.match?(first_codex, second_codex)
      return false if first_codex.empty? || second_codex.empty?
      return false if (first_codex.length - second_codex.length).abs >= 3

      combined_length = first_codex.length + second_codex.length
      need = if combined_length <= 4
               5
             elsif combined_length <= 7
               4
             elsif combined_length <= 11
               3
             else
               2
             end

      first_remainder = +""
      second_remainder = +""
      pass_length = [first_codex.length, second_codex.length].max

      pass_length.times do |index|
        first_character = first_codex[index]
        second_character = second_codex[index]
        next if first_character && first_character == second_character

        first_remainder << first_character if first_character
        second_remainder << second_character if second_character
      end

      first_reversed = first_remainder.reverse
      second_reversed = second_remainder.reverse
      unmatched_first = 0
      unmatched_second = 0
      pass_length = [first_reversed.length, second_reversed.length].max

      pass_length.times do |index|
        first_character = first_reversed[index]
        second_character = second_reversed[index]
        next if first_character && first_character == second_character

        unmatched_first += 1 if first_character
        unmatched_second += 1 if second_character
      end

      6 - [unmatched_first, unmatched_second].max >= need
    end
  end
end
