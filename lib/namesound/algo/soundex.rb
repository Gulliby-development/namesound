# frozen_string_literal: true

module Namesound
  module Algo
    module Soundex
      def self.key(word)
        return +"" if word.empty?

        result = +""
        result << word[0]
        previous = case word[0]
                   when "B", "F", "P", "V"
                     "1"
                   when "C", "G", "J", "K", "Q", "S", "X", "Z"
                     "2"
                   when "D", "T"
                     "3"
                   when "L"
                     "4"
                   when "M", "N"
                     "5"
                   when "R"
                     "6"
                   end

        word.each_char.with_index do |letter, index|
          next if index.zero?

          case letter
          when "H", "W"
            next
          when "A", "E", "I", "O", "U", "Y"
            previous = nil
            next
          end

          digit = case letter
                  when "B", "F", "P", "V"
                    "1"
                  when "C", "G", "J", "K", "Q", "S", "X", "Z"
                    "2"
                  when "D", "T"
                    "3"
                  when "L"
                    "4"
                  when "M", "N"
                    "5"
                  when "R"
                    "6"
                  end

          result << digit if digit != previous
          previous = digit
          break if result.length == 4
        end

        result.ljust(4, "0")
      end
    end
  end
end
