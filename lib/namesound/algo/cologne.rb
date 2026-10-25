# frozen_string_literal: true

module Namesound
  module Algo
    module Cologne
      def self.key(word)
        digits = +""
        previous = nil

        word.each_char.with_index do |letter, index|
          before = index.positive? ? word[index - 1] : nil
          after = word[index + 1]

          emitted = case letter
                    when "A", "E", "I", "J", "O", "U", "Y"
                      "0"
                    when "H"
                      ""
                    when "B"
                      "1"
                    when "P"
                      after == "H" ? "3" : "1"
                    when "D", "T"
                      after && "CSZ".include?(after) ? "8" : "2"
                    when "F", "V", "W"
                      "3"
                    when "G", "K", "Q"
                      "4"
                    when "X"
                      before && "CKQ".include?(before) ? "8" : "48"
                    when "L"
                      "5"
                    when "M", "N"
                      "6"
                    when "R"
                      "7"
                    when "S", "Z"
                      "8"
                    when "C"
                      if index.zero?
                        after && "AHKLOQRUX".include?(after) ? "4" : "8"
                      elsif (before && "SZ".include?(before)) || !(after && "AHKOQUX".include?(after))
                        "8"
                      else
                        "4"
                      end
                    end

          emitted.each_char do |digit|
            next if digit == previous

            digits << digit
            previous = digit
          end
        end

        key = +""
        digits.each_char.with_index do |digit, index|
          key << digit unless digit == "0" && !index.zero?
        end
        key
      end
    end
  end
end
