# frozen_string_literal: true

require_relative "../../lib/namesound/algo/nysiis"

RSpec.describe Namesound::Algo::Nysiis do
  it "returns an empty key for an empty folded word" do
    expect(described_class.key("")).to eq("")
  end

  it "produces the literal NYSIIS worked examples and replacement cases" do
    [
      %w[MACINTOSH MCANT],
      %w[MACDONALD MCDANA],
      %w[KNUTH NAT],
      %w[KANE CAN],
      %w[KATZ CAT],
      %w[PHELPS FALP],
      %w[PFAU F],
      %w[LEE LY],
      %w[TIE TY],
      %w[HURT HAD],
      %w[LAND LAD],
      %w[NORDT NARD],
      %w[STEVENS STAFAN],
      %w[EVAN EVAN],
      %w[QUEEN QAN],
      %w[MAZUR MASAR],
      %w[ZELDA ZALD],
      %w[MIMI MAN],
      %w[JOHNSON JANSAN],
      %w[HAHN HAN],
      %w[HOE H],
      %w[WAUGH WAG],
      %w[WOW W],
      %w[SHAW S],
      %w[HEYWOOD HAYWAD],
      %w[MAYS MY],
      %w[JAY JY],
      %w[GRAY GRY],
      %w[MIA M],
      %w[MURRAY MARY],
      %w[WESTERMAN WASTAR],
      %w[JOHNSTON JANSTA],
      %w[SCHB SB],
      %w[ABEE ABY],
      %w[ABIE ABY],
      %w[ABDT ABD],
      %w[ABRT ABD],
      %w[ABRD ABD],
      %w[ABNT ABD],
      %w[ABND ABD]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "consumes scan patterns and uses original changed-word neighbors" do
    [
      ["AKNA", "AN"],
      ["ASCHA", "AS"],
      ["APHA", "AF"],
      ["AEVA", "AF"],
      ["AEHA", "AH"],
      ["AYHA", "AY"],
      ["AH", ""],
      ["ASA", "AS"],
      ["ABAYS", "ABY"],
      ["ABCDEFG", "ABCDAF"],
      ["ABCDEFGH", "ABCDAF"]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end

  it "keeps six characters at the boundary and truncates longer keys" do
    [
      %w[ABCDEF ABCDAF],
      %w[ABCDEFG ABCDAF],
      %w[ABCDEFGH ABCDAF]
    ].each do |word, expected|
      expect(described_class.key(word)).to eq(expected)
    end
  end
end
