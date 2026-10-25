# frozen_string_literal: true

require_relative "../../lib/namesound/algo/metaphone"

RSpec.describe Namesound::Algo::Metaphone do
  it "handles start prefixes and first-read vowels" do
    [
      ["", ""],
      ["AEON", "EN"],
      ["GNOME", "NM"],
      ["KNIFE", "NF"],
      ["PNEUMONIA", "NMN"],
      ["WRIGHT", "RT"],
      ["XAVIER", "SFR"],
      ["XENON", "SNN"],
      ["WHALE", "WL"],
      ["WHICH", "WX"],
      ["ALICE", "ALS"],
      ["ELLEN", "ELN"],
      ["AERODROME", "ERTRM"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "applies duplicate suppression before the early letter rules" do
    [
      ["HANNAH", +"HN"],
      ["ACCRA", +"AKKR"],
      ["FIZZ", +"FS"],
      ["DUMB", +"TM"],
      ["LAMBS", +"LMBS"],
      ["NUMBER", +"NMBR"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "handles c contexts and precedence" do
    [
      ["FACIAL", +"FXL"],
      ["CHAT", +"XT"],
      ["SCHOOL", +"SKL"],
      ["SCHISM", +"SKSM"],
      ["SCIENCE", +"SNS"],
      ["SCENE", +"SN"],
      ["SCYTHE", +"S0"],
      ["CELL", +"SL"],
      ["CAT", +"KT"],
      ["CYST", +"SST"],
      ["CIA", +"X"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "handles d contexts and consumption" do
    [
      ["EDGE", +"EJ"],
      ["EDGY", +"EJ"],
      ["JUDGE", +"JJ"],
      ["DODGE", +"TJ"],
      ["DOG", +"TK"],
      ["DGYHA", +"JH"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "handles start boundaries and original skipped neighbors" do
    [
      ["A", +"A"],
      ["AA", +"A"],
      ["AE", +"E"],
      ["X", +"S"],
      ["WH", +"W"],
      ["BMB", +"BM"],
      ["GNN", +"N"],
      ["CCA", +"KK"],
      ["WHHA", +"W"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end
end
