# frozen_string_literal: true

require_relative "../../lib/namesound/algo/match_rating"

RSpec.describe Namesound::Algo::MatchRating do
  it "returns an empty codex for an empty word" do
    expect(described_class.key("")).to eq("")
  end

  it "produces the literal worked codices" do
    [
      %w[BYRNE BYRN],
      %w[BOERN BRN],
      %w[SMITH SMTH],
      %w[SMYTH SMYTH],
      %w[CATHERINE CTHRN],
      %w[HANNAH HNH],
      %w[ALEXANDRIA ALXNDR],
      %w[WASHINGTON WSHGTN],
      %w[AARON ARN],
      %w[JOHNATHAN JHNTHN],
      %w[JONATHAN JNTHN],
      %w[NG NG],
      %w[A A]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "removes vowels before collapsing runs and truncates only beyond six letters" do
    [
      %w[BAB B],
      %w[AEIOU A],
      %w[YAY Y],
      %w[BYC BYC],
      %w[BCDFG BCDFG],
      %w[BCDFGH BCDFGH],
      %w[BCDFGHJ BCDGHJ]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end
end
