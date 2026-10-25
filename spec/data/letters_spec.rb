# frozen_string_literal: true

require_relative "../../lib/namesound/data/letters"

RSpec.describe Namesound::Letters do
  describe ".fold" do
    it "folds empty and ASCII input" do
      [
        ["", ""],
        ["ABCDEFGHIJKLMNOPQRSTUVWXYZ", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"],
        ["abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
      ].each do |input, expected|
        expect(described_class.fold(input)).to eq(expected)
      end
    end

    it "folds every enumerated non-ASCII letter" do
      [
        %w[ÀÁÂÃÄÅ AAAAAA],
        %w[àáâãäå AAAAAA],
        %w[Ææ AEAE],
        %w[Çç CC],
        %w[ÈÉÊË EEEE],
        %w[èéêë EEEE],
        %w[ÌÍÎÏ IIII],
        %w[ìíîï IIII],
        %w[Ðð DD],
        %w[Ññ NN],
        %w[ÒÓÔÕÖØ OOOOOO],
        %w[òóôõöø OOOOOO],
        %w[ÙÚÛÜ UUUU],
        %w[ùúûü UUUU],
        %w[Ýýÿ YYY],
        %w[Þþ THTH],
        %w[ß SS],
        %w[Œœ OEOE],
        %w[Šš SS],
        %w[Žž ZZ],
        %w[Łł LL]
      ].each do |input, expected|
        expect(described_class.fold(input)).to eq(expected)
      end
    end

    it "folds mixed names and drops unlisted code points" do
      [
        ["O'Brien-Smith 2nd", "OBRIENSMITHND"],
        ["Über", "UBER"],
        ["Straße", "STRASSE"],
        ["e\u0301", "E"],
        ["×÷ªµıſK\u0301ЖΩ中😀", ""],
        ["0123456789'- \t\r\n\u0000\u00A0\u0085\u3000\uFEFF", ""],
        ["aÆ-ßŒþz", "AAESSOETHZ"]
      ].each do |input, expected|
        expect(described_class.fold(input)).to eq(expected)
      end
    end

    it "accepts frozen input without modifying it" do
      input = "Straße"

      expect(input).to be_frozen
      expect(described_class.fold(input)).to eq("STRASSE")
      expect(input).to eq("Straße")
    end

    it "does not modify mutable input" do
      input = +"Straße"

      expect(described_class.fold(input)).to eq("STRASSE")
      expect(input).to eq("Straße")
    end
  end
end
