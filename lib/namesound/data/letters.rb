# frozen_string_literal: true

module Namesound
  module Letters
    def self.fold(text)
      folded = +""
      text.each_codepoint do |codepoint|
        letters = case codepoint
                  when 0x0041..0x005A then codepoint.chr(Encoding::UTF_8)
                  when 0x0061..0x007A then (codepoint - 32).chr(Encoding::UTF_8)
                  when 0x00C0..0x00C5, 0x00E0..0x00E5 then "A"
                  when 0x00C6, 0x00E6 then "AE"
                  when 0x00C7, 0x00E7 then "C"
                  when 0x00C8..0x00CB, 0x00E8..0x00EB then "E"
                  when 0x00CC..0x00CF, 0x00EC..0x00EF then "I"
                  when 0x00D0, 0x00F0 then "D"
                  when 0x00D1, 0x00F1 then "N"
                  when 0x00D2..0x00D6, 0x00D8, 0x00F2..0x00F6, 0x00F8 then "O"
                  when 0x00D9..0x00DC, 0x00F9..0x00FC then "U"
                  when 0x00DD, 0x00FD, 0x00FF then "Y"
                  when 0x00DE, 0x00FE then "TH"
                  when 0x00DF then "SS"
                  when 0x0152, 0x0153 then "OE"
                  when 0x0160, 0x0161 then "S"
                  when 0x017D, 0x017E then "Z"
                  when 0x0141, 0x0142 then "L"
                  end
        folded << letters if letters
      end
      folded
    end
  end
end
