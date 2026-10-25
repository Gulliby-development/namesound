# frozen_string_literal: true

require_relative "../../lib/namesound/base/inputs"
require_relative "../../lib/namesound/base/grid"

RSpec.describe Namesound::Inputs do
  let(:io) do
    Class.new do
      attr_accessor :stdin_bytes, :stdin_error
      attr_reader :stdin_reads, :file_reads, :files, :file_errors

      def initialize
        @stdin_bytes = +""
        @stdin_error = false
        @stdin_reads = 0
        @file_reads = []
        @files = {}
        @file_errors = []
      end

      def read_stdin
        @stdin_reads += 1
        raise IOError if @stdin_error

        @stdin_bytes
      end

      def read_file(path)
        @file_reads << path
        raise IOError if @file_errors.include?(path)

        @files.fetch(path)
      end
    end.new
  end

  it "reads stdin once and preserves its label, UTF-8 text, BOM, and line endings" do
    io.stdin_bytes = "\uFEFFé\r\n".b
    inputs = described_class.new(io)
    source = inputs.read("-")

    expect(source.members).to eq(%i[label text])
    expect(source.label).to eq("<stdin>")
    expect(source.text).to eq("\uFEFFé\r\n")
    expect(source.text.encoding).to eq(Encoding::UTF_8)
    expect { inputs.read("-") }.to raise_error(Namesound::Failure, "standard input is named twice")
    expect(io.stdin_reads).to eq(1)
  end

  it "reads empty stdin as an empty UTF-8 source" do
    source = described_class.new(io).read("-")

    expect(source.label).to eq("<stdin>")
    expect(source.text).to eq("")
    expect(source.text.encoding).to eq(Encoding::UTF_8)
  end

  it "reads repeated files again with the original path and a plain label" do
    io.files["café"] = "A\rB\n".b
    inputs = described_class.new(io)
    first = inputs.read("café")
    second = inputs.read("café")

    expect(io.file_reads).to eq(%w[café café])
    expect(first.members).to eq(%i[label text])
    expect(first.label).to eq("caf?")
    expect(first.text).to eq("A\rB\n")
    expect(second.label).to eq("caf?")
    expect(second.text).to eq("A\rB\n")
  end

  it "turns stdin and file read failures into labeled failures" do
    io.stdin_error = true
    io.file_errors << "café"

    expect { described_class.new(io).read("-") }
      .to raise_error(Namesound::Failure, "<stdin>: cannot read the file")
    expect { described_class.new(io).read("café") }
      .to raise_error(Namesound::Failure, "caf?: cannot read the file")
    expect(io.file_reads).to eq(["café"])
  end

  it "rejects malformed stdin and file bytes as invalid UTF-8" do
    io.stdin_bytes = "a\xFF\n".b

    expect { described_class.new(io).read("-") }
      .to raise_error(Namesound::Failure, "<stdin>: input is not valid UTF-8")

    [
      ["g", "\xC0\xAF".b, "g: input is not valid UTF-8"],
      ["g", "\xED\xA0\x80".b, "g: input is not valid UTF-8"],
      ["g", "\xF4\x90\x80\x80".b, "g: input is not valid UTF-8"],
      ["g", "\xE2\x82".b, "g: input is not valid UTF-8"]
    ].each do |argument, bytes, message|
      io.files[argument] = bytes
      expect { described_class.new(io).read(argument) }.to raise_error(Namesound::Failure, message)
    end
  end

  it "extracts entries using LF, one trailing CR, and SPACE/TAB trimming only" do
    [
      ["", []],
      [" \t\r\n\n", []],
      [" \tRobert\t \r\nRupert\nRobert\r", %w[Robert Rupert Robert]],
      ["A\r\r\nB\r \nC\rD", ["A\r", "B\r", "C\rD"]],
      ["\uFEFFX\n\u00A0Y\u0085\n\u3000Z\u3000\n\u0000", ["\uFEFFX", "\u00A0Y\u0085", "\u3000Z\u3000", "\u0000"]]
    ].each do |text, expected|
      expect(described_class.entries(text)).to eq(expected)
    end
  end

  it "renders empty, code-point padded, independently sized, and single-column grids" do
    [
      [[], ""],
      [
        [["NAME", "KEY"], ["é", "X"], ["😀ab", "YZ"]],
        "NAME  KEY\né     X\n😀ab   YZ\n"
      ],
      [
        [%w[A B C], %w[long xx z]],
        "A     B   C\nlong  xx  z\n"
      ],
      [[["solo"]], "solo\n"]
    ].each do |rows, expected|
      expect(Namesound::Grid.render(rows)).to eq(expected)
    end
  end
end
