# frozen_string_literal: true

require_relative "../../lib/namesound/data/algorithms"
require_relative "../../lib/namesound/key/keyer"

RSpec.describe "Keyer and algorithm metadata" do
  it "exposes the exact metadata members and ordered rows" do
    expect(Namesound::Algorithms::Entry.members).to eq(%i[name key_length about])

    entries = Namesound::Algorithms.all
    [
      [0, "soundex", "4 chars", "American Soundex"],
      [1, "refined", "any length", "Refined Soundex"],
      [2, "nysiis", "6 chars", "NYSIIS, cut at 6"],
      [3, "metaphone", "any length", "original Metaphone"],
      [4, "cologne", "digits", "Cologne phonetics (German)"],
      [5, "mra", "6 chars", "Match Rating Approach codex"]
    ].each do |index, name, key_length, about|
      entry = entries[index]
      expect([entry.name, entry.key_length, entry.about]).to eq([name, key_length, about])
    end
  end

  it "returns distinct mutable arrays without changing later metadata results" do
    first = Namesound::Algorithms.all
    second = Namesound::Algorithms.all

    expect(first).not_to equal(second)
    first.reverse!
    expect(second.map(&:name)).to eq(%w[soundex refined nysiis metaphone cologne mra])
    expect(Namesound::Algorithms.all.map(&:name)).to eq(
      %w[soundex refined nysiis metaphone cologne mra]
    )
  end

  it "finds canonical and ASCII-case-insensitive names and rejects other values" do
    [
      %w[soundex soundex],
      %w[SOUNDEX soundex],
      %w[ReFiNeD refined],
      %w[NYSIIS nysiis],
      %w[MetaPhone metaphone],
      %w[COLOGNE cologne],
      %w[MRA mra]
    ].each do |query, expected|
      expect(Namesound::Algorithms.find(query)&.name).to eq(expected)
    end

    ["unknown", "Soundex!", "mra "].each do |query|
      expect(Namesound::Algorithms.find(query)).to be_nil
    end
  end

  it "dispatches each canonical algorithm to its key implementation" do
    [
      %w[soundex Robert R163],
      %w[refined Braz B1905],
      %w[nysiis Macintosh MCANT],
      %w[metaphone Whale WL],
      %w[cologne Wikipedia 3412],
      %w[mra Byrne BYRN]
    ].each do |algorithm, text, expected|
      expect(Namesound::Keyer.key(algorithm, text)).to eq(expected)
    end
  end

  it "folds lowercase, punctuation, accents, and expansions before dispatch" do
    [
      %w[soundex robert R163],
      %w[soundex Ro-bert R163],
      %w[cologne Müller-Lüdenscheidt 65752682],
      %w[mra Straße STRS]
    ].each do |algorithm, text, expected|
      expect(Namesound::Keyer.key(algorithm, text)).to eq(expected)
    end
  end

  it "returns empty keys for empty and unrecognized-letter input on every algorithm" do
    [
      ["soundex", "", ""],
      ["refined", "", ""],
      ["nysiis", "", ""],
      ["metaphone", "", ""],
      ["cologne", "", ""],
      ["mra", "", ""],
      ["soundex", "1234", ""],
      ["refined", "1234", ""],
      ["nysiis", "1234", ""],
      ["metaphone", "1234", ""],
      ["cologne", "1234", ""],
      ["mra", "1234", ""]
    ].each do |algorithm, text, expected|
      expect(Namesound::Keyer.key(algorithm, text)).to eq(expected)
    end
  end

  it "handles NYSIIS and other algorithm-specific empty-key cases" do
    [
      ["nysiis", "Aha", "AH"],
      ["nysiis", "Awe", ""],
      ["metaphone", "H", ""],
      ["cologne", "H", ""]
    ].each do |algorithm, text, expected|
      expect(Namesound::Keyer.key(algorithm, text)).to eq(expected)
    end
  end

  it "raises exact failures for noncanonical algorithm names" do
    [
      ["unknown", "unknown algorithm \"unknown\""],
      ["", "unknown algorithm \"\""],
      ["Soundex", "unknown algorithm \"Soundex\""],
      ["\u0001", "unknown algorithm \"?\""],
      ["é", "unknown algorithm \"?\""],
      ["bad\"name", "unknown algorithm \"bad\"name\""]
    ].each do |algorithm, expected|
      expect { Namesound::Keyer.key(algorithm, "Robert") }
        .to raise_error(Namesound::Failure, expected)
    end
  end

  it "dispatches through the canonical entry returned by metadata lookup" do
    [
      %w[SOUNDEX Robert R163],
      %w[REFINED Braz B1905],
      %w[NYSIIS Macintosh MCANT],
      %w[METAPHONE Whale WL],
      %w[COLOGNE Wikipedia 3412],
      %w[MRA Byrne BYRN]
    ].each do |query, text, expected|
      algorithm = Namesound::Algorithms.find(query)
      expect(Namesound::Keyer.key(algorithm.name, text)).to eq(expected)
    end
  end
end
