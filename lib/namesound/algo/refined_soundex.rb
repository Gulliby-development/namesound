# frozen_string_literal: true

module Namesound
  module Algo
    module RefinedSoundex
      def self.key(word)
        return +"" if word.empty?

        digits = "01360240043788015936020505"
        result = +""
        result << word[0]
        previous_digit = nil

        word.each_byte do |letter|
          digit = digits.getbyte(letter - 65)
          result << digit unless digit == previous_digit
          previous_digit = digit
        end

        result
      end
    end
  end
end
