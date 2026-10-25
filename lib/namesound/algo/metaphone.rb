# frozen_string_literal: true

module Namesound
  module Algo
    module Metaphone
      def self.key(word)
        key = +""
        index = 0

        if word.start_with?("AE", "GN", "KN", "PN", "WR")
          index = 1
        elsif word.start_with?("X")
          key << "S"
          index = 1
        elsif word.start_with?("WH")
          key << "W"
          index = 2
        end

        first_read = index
        length = word.length

        while index < length
          letter = word[index]
          before = index.positive? ? word[index - 1] : nil
          after = index + 1 < length ? word[index + 1] : nil
          after2 = index + 2 < length ? word[index + 2] : nil
          consumed = 1

          if letter == before && letter != "C"
            # Duplicate suppression has precedence over all letter rules.
          elsif "AEIOU".include?(letter)
            key << letter if index == first_read && key.empty?
          else
            case letter
            when "B"
              key << "B" unless before == "M" && index == length - 1
            when "C"
              if after == "I" && after2 == "A"
                key << "X"
              elsif after == "H"
                key << (before == "S" ? "K" : "X")
                consumed = 2
              elsif after && "IEY".include?(after)
                key << "S" unless before == "S"
              else
                key << "K"
              end
            when "D"
              if after == "G" && after2 && "EIY".include?(after2)
                key << "J"
                consumed = 2
              else
                key << "T"
              end
            when "G"
              if after == "H"
                key << "K" if after2.nil? || "AEIOU".include?(after2)
                consumed = 2
              elsif after == "N"
                suffix_is_gned = index + 4 == length && word[index + 1, 3] == "NED"
                n_is_final = index + 2 == length
                key << "K" unless n_is_final || suffix_is_gned
              elsif after && "IEY".include?(after)
                key << "J" unless before == "G"
              else
                key << "K"
              end
            when "H"
              key << "H" if after && "AEIOU".include?(after) && (before.nil? || !"CGPST".include?(before))
            when "K"
              key << "K" unless before == "C"
            when "P"
              if after == "H"
                key << "F"
                consumed = 2
              else
                key << "P"
              end
            when "Q"
              key << "K"
            when "S"
              if after == "H"
                key << "X"
                consumed = 2
              elsif after == "I" && after2 && "OA".include?(after2)
                key << "X"
              else
                key << "S"
              end
            when "T"
              if after == "I" && after2 && "AO".include?(after2)
                key << "X"
              elsif after == "H"
                key << "0"
                consumed = 2
              elsif after == "C" && after2 == "H"
                # TCH suppresses only the T; C is read by the next iteration.
              else
                key << "T"
              end
            when "V"
              key << "F"
            when "W", "Y"
              key << letter if after && "AEIOU".include?(after)
            when "X"
              key << "KS"
            when "Z"
              key << "S"
            when "F", "J", "L", "M", "N", "R"
              key << letter
            end
          end

          index += consumed
        end

        key
      end
    end
  end
end
