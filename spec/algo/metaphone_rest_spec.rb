# frozen_string_literal: true

require_relative "../../lib/namesound/algo/metaphone"

RSpec.describe Namesound::Algo::Metaphone do
  it "handles GH and GN branches with original-word context" do
    [
      ["GHOST", "KST"],
      ["LIGHT", "LT"],
      ["HIGH", "HK"],
      ["LAUGH", "LK"],
      ["SIGN", "SN"],
      ["SIGNED", "SNT"],
      ["SIGNAL", "SKNL"],
      ["GONE", "KN"],
      ["GENTLE", "JNTL"],
      ["GIANT", "JNT"],
      ["EGG", "EK"],
      ["GH", "K"],
      ["GHA", "K"],
      ["GHY", ""],
      ["AGGN", "AKN"],
      ["AGGIE", "AK"],
      ["SIGNEDA", "SKNT"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "applies H, K, P, and Q rules" do
    [
      %w[HAT HT],
      %w[AH A],
      %w[KHAN KHN],
      %w[BACK BK],
      %w[SICK SK],
      %w[PHONE FN],
      %w[GRAPH KRF],
      %w[QUEEN KN],
      %w[HAH H],
      %w[AHA AH],
      %w[CHA X],
      %w[PHA F],
      %w[SHA X],
      %w[THA 0],
      %w[APA AP]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "applies S and T precedence and consumption rules" do
    [
      %w[SHOW X],
      %w[PASSION PSN],
      %w[MISSION MSN],
      %w[NATION NXN],
      %w[THING 0NK],
      %w[THAT 0T],
      %w[MATCH MX],
      %w[LATCH LX],
      %w[SIA X],
      %w[SIO X],
      %w[TIA X],
      %w[SIAHA XH],
      %w[TIOHA XH],
      %w[SHHA X],
      %w[THT 0T]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "applies V, W, and Y rules at word boundaries" do
    [
      ["VASE", "FS"],
      ["WOW", "W"],
      ["AWE", "AW"],
      ["YES", "YS"],
      ["JOY", "J"],
      ["W", ""],
      ["Y", ""],
      ["WY", ""],
      ["YA", "Y"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "handles X, Z, unchanged consonants, empty output, and unrestricted length" do
    [
      ["BOX", "BKS"],
      ["ZOO", "S"],
      ["FJLMNR", "FJLMNR"],
      ["FJLMNRFJLMNR", "FJLMNRFJLMNR"],
      ["AXAXAXAX", "AKSKSKSKS"],
      ["H", ""],
      ["HMM", "M"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end
end
