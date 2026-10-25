# frozen_string_literal: true

require_relative "../../lib/namesound/algo/cologne"

RSpec.describe Namesound::Algo::Cologne do
  describe ".key" do
    it "returns an empty key for an empty folded word" do
      expect(described_class.key("")).to eq("")
    end

    it "matches the literal worked examples" do
      [
        %w[WIKIPEDIA 3412],
        %w[BRESCHNEW 17863],
        %w[POSTEL 1825],
        %w[HANS 068],
        %w[CHRISTOPH 47823],
        %w[XYLOPHONE 48536],
        %w[AXE 048],
        %w[FIX 348],
        %w[TAMM 26],
        %w[SCHMIDT 862],
        %w[ZERR 87],
        %w[ACH 04],
        %w[CZECH 84],
        %w[BACH 14],
        %w[THOMAS 268],
        %w[LUTZ 58],
        %w[MULLERLUDENSCHEIDT 65752682],
        %w[MUELLER 657]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end

    it "maps digit categories and X contexts literally" do
      [
        ["A", "0"],
        ["E", "0"],
        ["I", "0"],
        ["J", "0"],
        ["O", "0"],
        ["U", "0"],
        ["Y", "0"],
        ["H", ""],
        ["B", "1"],
        ["P", "1"],
        ["D", "2"],
        ["T", "2"],
        ["F", "3"],
        ["V", "3"],
        ["W", "3"],
        ["G", "4"],
        ["K", "4"],
        ["Q", "4"],
        ["X", "48"],
        ["KX", "48"],
        ["QX", "48"],
        ["L", "5"],
        ["M", "6"],
        ["N", "6"],
        ["R", "7"],
        ["S", "8"],
        ["Z", "8"],
        ["C", "8"]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end

    it "uses the initial C rule and its following letter" do
      [
        %w[CA 4],
        %w[CH 4],
        %w[CK 4],
        %w[CL 45],
        %w[CO 4],
        %w[CQ 4],
        %w[CR 47],
        %w[CU 4],
        %w[CX 48],
        %w[CB 81],
        %w[CF 83],
        %w[CS 8],
        %w[CZ 8]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end

    it "uses original neighbors for internal C" do
      [
        %w[ACA 04],
        %w[ACH 04],
        %w[ACK 04],
        %w[ACO 04],
        %w[ACQ 04],
        %w[ACU 04],
        %w[ACX 048],
        %w[SCA 8],
        %w[ZCA 8],
        %w[ACL 085],
        %w[ACR 087]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end

    it "applies contextual P, D, and T rules" do
      [
        %w[P 1],
        %w[PH 3],
        %w[DCA 84],
        %w[DS 8],
        %w[TZ 8],
        %w[POSTEL 1825]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end

    it "collapses emitted digits before removing noninitial zeros" do
      [
        ["BHB", "1"],
        ["BAB", "11"],
        ["H", ""],
        ["HA", "0"],
        ["JY", "0"],
        ["DCA", "84"],
        ["DS", "8"],
        ["TZ", "8"]
      ].each do |word, expected|
        expect(described_class.key(word)).to eq(expected)
      end
    end
  end
end
