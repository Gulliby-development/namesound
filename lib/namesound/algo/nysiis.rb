# frozen_string_literal: true

module Namesound
  module Algo
    module Nysiis
      def self.key(word)
        return "" if word.empty?

        changed_word = word
        if changed_word.start_with?("MAC")
          changed_word = "MCC#{changed_word[3..]}"
        elsif changed_word.start_with?("KN")
          changed_word = "NN#{changed_word[2..]}"
        elsif changed_word.start_with?("K")
          changed_word = "C#{changed_word[1..]}"
        elsif changed_word.start_with?("PH", "PF")
          changed_word = "FF#{changed_word[2..]}"
        elsif changed_word.start_with?("SCH")
          changed_word = "SSS#{changed_word[3..]}"
        end

        if changed_word.end_with?("EE", "IE")
          changed_word = "#{changed_word[0...-2]}Y"
        elsif changed_word.end_with?("DT", "RT", "RD", "NT", "ND")
          changed_word = "#{changed_word[0...-2]}D"
        end

        key = +""
        key << changed_word[0]
        vowels = "AEIOU"
        index = 1

        while index < changed_word.length
          current = changed_word[index]
          emitted = ""
          consumed = 1

          if changed_word[index, 2] == "EV"
            emitted = "AF"
            consumed = 2
          elsif vowels.include?(current)
            emitted = "A"
          elsif current == "Q"
            emitted = "G"
          elsif current == "Z"
            emitted = "S"
          elsif current == "M"
            emitted = "N"
          elsif changed_word[index, 2] == "KN"
            emitted = "N"
            consumed = 2
          elsif current == "K"
            emitted = "C"
          elsif changed_word[index, 3] == "SCH"
            emitted = "SSS"
            consumed = 3
          elsif changed_word[index, 2] == "PH"
            emitted = "FF"
            consumed = 2
          elsif current == "H"
            after = changed_word[index + 1]
            emitted = "H" if vowels.include?(changed_word[index - 1]) && after && vowels.include?(after)
          elsif current == "W"
            emitted = "W" unless vowels.include?(changed_word[index - 1])
          else
            emitted = current
          end

          emitted.each_char do |letter|
            key << letter unless key[-1] == letter
          end

          index += consumed
        end

        key.chop! if key.end_with?("S")
        key = "#{key[0...-2]}Y" if key.end_with?("AY")
        key.chop! if key.end_with?("A")
        key = key[0, 6] if key.length > 6
        key
      end
    end
  end
end
