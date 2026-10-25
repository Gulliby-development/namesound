# frozen_string_literal: true

require_relative "../key/keyer"
require_relative "rating"

module Namesound
  module Similar
    def self.same?(algorithm, first_text, second_text)
      first_key = Keyer.key(algorithm, first_text)
      second_key = Keyer.key(algorithm, second_text)
      return false if first_key.empty? || second_key.empty?

      algorithm == "mra" ? Rating.match?(first_key, second_key) : first_key == second_key
    end
  end
end
