# frozen_string_literal: true

require_relative "../../lib/namesound/match/grouper"

RSpec.describe Namesound::Grouper do
  let(:entries) { %w[Robert Rupert Smith Smyth Schmidt Rubin Mueller Miller Moeller] }

  def pairs(groups)
    groups.map { |group| [group.key, group.names.length] }
  end

  it "keeps the key order when no order is given" do
    expect(pairs(described_class.group("soundex", entries, 1))).to eq(
      [["M460", 3], ["R150", 1], ["R163", 2], ["S530", 3]]
    )
  end

  it "keeps the key order for the order key" do
    expect(pairs(described_class.group("soundex", entries, 1, "key"))).to eq(
      [["M460", 3], ["R150", 1], ["R163", 2], ["S530", 3]]
    )
  end

  it "puts the larger groups first and breaks ties by key for the order count" do
    expect(pairs(described_class.group("soundex", entries, 1, "count"))).to eq(
      [["M460", 3], ["S530", 3], ["R163", 2], ["R150", 1]]
    )
  end

  it "applies the minimum before the order" do
    expect(pairs(described_class.group("soundex", entries, 2, "count"))).to eq(
      [["M460", 3], ["S530", 3], ["R163", 2]]
    )
  end

  it "keeps the first-appearance order of the names inside a group" do
    groups = described_class.group("soundex", entries, 2, "count")
    expect(groups.map(&:names)).to eq([%w[Mueller Miller Moeller], %w[Smith Smyth Schmidt], %w[Robert Rupert]])
  end
end
