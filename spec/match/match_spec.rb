# frozen_string_literal: true

require_relative "../../lib/namesound/match/rating"
require_relative "../../lib/namesound/match/similar"
require_relative "../../lib/namesound/match/grouper"

RSpec.describe Namesound::Rating do
  it "matches literal codex acceptance pairs" do
    [
      ["", "A", false],
      ["A", "", false],
      ["", "", false],
      ["ABCDEF", "ABC", false],
      ["AB", "ABCDE", false],
      ["ABCDEF", "ABCX", true],
      ["XY", "XZ", true],
      ["ABCD", "WXYZ", false],
      ["LONGER", "LONG", true],
      ["BRN", "BRNX", true],
      ["AAAA", "BBBB", false]
    ].each do |first, second, expected|
      expect(described_class.match?(first, second)).to eq(expected)
    end
  end

  it "uses original length thresholds and both positional cancellation passes" do
    [
      ["AB", "CD", false],
      ["AB", "ACD", true],
      ["ABC", "ADEF", false],
      ["ABC", "ABDX", true],
      ["ABCD", "AXYZ", true],
      ["ABCDE", "ABCXYZ", true],
      ["ABCDEF", "ABWXYZ", true],
      ["ABC", "XABC", true],
      ["ABC", "BCA", false],
      ["BYRN", "BRN", true],
      ["SMTH", "SMYTH", true],
      ["CTHRN", "KTHRN", true],
      ["HNH", "HN", true],
      ["NG", "NGYN", true],
      ["RBRT", "RPRT", true],
      ["SMTH", "JNS", false],
      ["RBRT", "SMTH", false]
    ].each do |first, second, expected|
      expect(described_class.match?(first, second)).to eq(expected)
    end
  end
end

RSpec.describe Namesound::Similar do
  it "compares literal names through each canonical algorithm" do
    [
      ["soundex", "Smith", "Smyth", true],
      ["refined", "Smith", "Smyth", true],
      ["nysiis", "Smith", "Smyth", false],
      ["metaphone", "Robert", "Rupert", false],
      ["mra", "Robert", "Rupert", true],
      ["cologne", "Mueller", "Müller", true],
      ["soundex", "Robert", "1234", false],
      ["soundex", "1234", "Robert", false],
      ["soundex", "1234", "5678", false],
      ["nysiis", "Aha", "Awe", false],
      ["metaphone", "Hmm", "H", false]
    ].each do |algorithm, first, second, expected|
      expect(described_class.same?(algorithm, first, second)).to eq(expected)
    end
  end
end

RSpec.describe Namesound::Grouper do
  it "returns stable groups by key equality for literal entry lists" do
    [
      [
        "soundex",
        %w[Robert Rupert Rubin Smith Smyth Schmidt Schmitt Mueller Müller Miller 1234
           Smith Smith],
        2,
        [
          Namesound::Grouper::Group.new("M460", %w[Mueller Müller Miller]),
          Namesound::Grouper::Group.new("R163", %w[Robert Rupert]),
          Namesound::Grouper::Group.new("S530", %w[Smith Smyth Schmidt Schmitt])
        ]
      ],
      [
        "soundex",
        %w[Rupert Robert Rupert robert],
        2,
        [Namesound::Grouper::Group.new("R163", %w[Rupert Robert robert])]
      ],
      ["soundex", %w[Robert Robert], 2, []],
      ["soundex", %w[Rubin 1234], 1, [Namesound::Grouper::Group.new("R150", ["Rubin"])]],
      ["soundex", %w[Robert Rupert Rubin], 3, []],
      ["soundex", [], 2, []],
      [
        "mra",
        %w[Robert Rupert Robert robert],
        1,
        [
          Namesound::Grouper::Group.new("RBRT", %w[Robert robert]),
          Namesound::Grouper::Group.new("RPRT", ["Rupert"])
        ]
      ],
      ["mra", %w[Robert Rupert], 2, []],
      [
        "nysiis",
        %w[Aha Awe],
        1,
        [Namesound::Grouper::Group.new("AH", ["Aha"])]
      ]
    ].each do |algorithm, entries, minimum, expected_groups|
      groups = described_class.group(algorithm, entries, minimum)
      expect([described_class::Group.members, groups]).to eq([%i[key names], expected_groups])
    end
  end
end
