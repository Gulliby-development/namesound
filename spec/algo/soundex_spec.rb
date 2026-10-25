# frozen_string_literal: true

require_relative "../../lib/namesound/algo/soundex"
require_relative "../../lib/namesound/algo/refined_soundex"

RSpec.describe "Soundex algorithms" do
  it "returns an empty key for empty American input" do
    expect(Namesound::Algo::Soundex.key("")).to eq("")
  end

  it "returns an empty key for empty Refined input" do
    expect(Namesound::Algo::RefinedSoundex.key("")).to eq("")
  end

  it "matches American Soundex worked examples and core boundaries" do
    [
      %w[ROBERT R163],
      %w[RUPERT R163],
      %w[RUBIN R150],
      %w[JACKSON J250],
      %w[LEE L000],
      %w[LLOYD L300],
      %w[WU W000],
      %w[A A000],
      %w[HILL H400],
      %w[PFISTER P236],
      %w[ASHCRAFT A261],
      %w[TYMCZAK T522],
      %w[HONEYMAN H555],
      %w[WASHINGTON W252],
      %w[BHB B000],
      %w[BWB B000],
      %w[BABEBIBOBUBYB B111],
      %w[ABFPVCGJKQSXZDTLMNR A123]
    ].each do |word, expected|
      expect(Namesound::Algo::Soundex.key(word)).to eq(expected)
    end
  end

  it "keeps H and W transparent and resets duplicate digits on every vowel" do
    [
      %w[BHB B000],
      %w[BWB B000],
      %w[BAB B100],
      %w[BEB B100],
      %w[BIB B100],
      %w[BOB B100],
      %w[BUB B100],
      %w[BYB B100]
    ].each do |word, expected|
      expect(Namesound::Algo::Soundex.key(word)).to eq(expected)
    end
  end

  it "maps all American consonant classes and pads short keys" do
    [
      %w[AL A400],
      %w[AM A500],
      %w[AN A500],
      %w[AR A600],
      %w[LEE L000],
      %w[WU W000]
    ].each do |word, expected|
      expect(Namesound::Algo::Soundex.key(word)).to eq(expected)
    end
  end

  it "matches Refined Soundex worked examples and core boundaries" do
    [
      %w[BRAZ B1905],
      %w[CAREN C30908],
      %w[HAYDEN H0608],
      %w[LIPPMANN L701808],
      %w[MARK M8093],
      %w[SMITH S38060],
      %w[A A0],
      %w[AARON A0908],
      %w[B B1],
      %w[BHB B101],
      %w[BWB B101],
      %w[AEHIOUWY A0],
      %w[BPFVCSKGJMNQXZDTRL B123485697],
      %w[BABABABABABAB B1010101010101]
    ].each do |word, expected|
      expect(Namesound::Algo::RefinedSoundex.key(word)).to eq(expected)
    end
  end

  it "suppresses adjacent Refined zero digits and preserves nonadjacent repetitions" do
    [
      %w[B B1],
      %w[BHB B101],
      %w[BWB B101],
      %w[AEHIOUWY A0],
      %w[BABABABABABAB B1010101010101]
    ].each do |word, expected|
      expect(Namesound::Algo::RefinedSoundex.key(word)).to eq(expected)
    end
  end

  it "uses every Refined Soundex alphabet digit without truncation" do
    expect(Namesound::Algo::RefinedSoundex.key("ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
      .to eq("A013602404378015936020505")
  end
end
