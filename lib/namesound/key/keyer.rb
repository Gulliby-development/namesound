# frozen_string_literal: true

require_relative "../base/failure"
require_relative "../base/text"
require_relative "../data/letters"
require_relative "../algo/soundex"
require_relative "../algo/refined_soundex"
require_relative "../algo/nysiis"
require_relative "../algo/metaphone"
require_relative "../algo/cologne"
require_relative "../algo/match_rating"

module Namesound
  module Keyer
    def self.key(algorithm, text)
      word = Letters.fold(text)

      case algorithm
      when "soundex" then Algo::Soundex.key(word)
      when "refined" then Algo::RefinedSoundex.key(word)
      when "nysiis" then Algo::Nysiis.key(word)
      when "metaphone" then Algo::Metaphone.key(word)
      when "cologne" then Algo::Cologne.key(word)
      when "mra" then Algo::MatchRating.key(word)
      else raise Failure, "unknown algorithm #{Text.show(algorithm)}"
      end
    end
  end
end
