# frozen_string_literal: true

require_relative "../../lib/namesound/base/inputs"
require_relative "../../lib/namesound/cmd/algorithms_command"
require_relative "../../lib/namesound/cmd/key_command"
require_relative "../../lib/namesound/cmd/group_command"
require_relative "../../lib/namesound/cmd/compare_command"

RSpec.describe Namesound do
  let(:io) do
    Class.new do
      attr_accessor :stdin_bytes
      attr_reader :file_reads, :files

      def initialize
        @stdin_bytes = +""
        @file_reads = []
        @files = {}
      end

      def read_stdin
        @stdin_bytes
      end

      def read_file(path)
        @file_reads << path
        @files.fetch(path)
      end
    end.new
  end

  let(:inputs) { Namesound::Inputs.new(io) }

  it "lists the canonical algorithms without reading input" do
    output = Namesound::AlgorithmsCommand.run([], Set.new, {}, inputs)

    expect(output.code).to eq(0)
    expect(output.out).to eq(<<~TEXT)
      NAME       KEY         ABOUT
      soundex    4 chars     American Soundex
      refined    any length  Refined Soundex
      nysiis     6 chars     NYSIIS, cut at 6
      metaphone  any length  original Metaphone
      cologne    digits      Cologne phonetics (German)
      mra        6 chars     Match Rating Approach codex
    TEXT
    expect(io.file_reads).to eq([])
  end

  it "renders the worked Soundex table and preserves duplicate entry order" do
    io.files["f"] =
      "Robert\nRupert\nRubin\nSmith\nSmyth\nSchmidt\nSchmitt\nMueller\nMüller\nMiller\n1234\n  Smith \nSmith\n".b

    output = Namesound::KeyCommand.run(%w[SOUNDEX f], Set.new, {}, inputs)

    expect(output.code).to eq(1)
    expect(output.out).to eq(<<~TEXT)
      NAME     KEY
      Robert   R163
      Rupert   R163
      Rubin    R150
      Smith    S530
      Smyth    S530
      Schmidt  S530
      Schmitt  S530
      Mueller  M460
      M?ller   M460
      Miller   M460
      1234     -
      Smith    S530
      Smith    S530
    TEXT
    expect(io.file_reads).to eq(["f"])
  end

  it "renders bare empty keys, empty stdin, and the corrected nonempty NYSIIS key" do
    io.files["f"] = "Robert\n1234\nRupert\n".b
    bare = Namesound::KeyCommand.run(%w[soundex f], Set.new(["--bare"]), {}, inputs)

    expect(bare.code).to eq(1)
    expect(bare.out).to eq("R163\n\nR163\n")

    io.stdin_bytes = +""
    empty = Namesound::KeyCommand.run(["soundex", "-"], Set.new, {}, Namesound::Inputs.new(io))

    expect(empty.code).to eq(0)
    expect(empty.out).to eq("")

    io.files["f"] = "Aha\n".b
    aha = Namesound::KeyCommand.run(%w[Nysiis f], Set.new, {}, Namesound::Inputs.new(io))

    expect(aha.code).to eq(0)
    expect(aha.out).to eq("NAME  KEY\nAha   AH\n")
  end

  it "merges ordered file entries into the worked Soundex groups" do
    io.files["f"] = "Robert\nRupert\nSmith\nSmyth\nMueller\n".b
    io.files["g"] = "Müller\nMiller\nSchmidt\nSchmitt\nSmith\n1234\nRubin\n".b

    output = Namesound::GroupCommand.run(%w[soundex f g], Set.new, {}, inputs)

    expect(output.code).to eq(0)
    expect(output.out).to eq(<<~TEXT)
      KEY   COUNT  NAMES
      M460  3      Mueller, M?ller, Miller
      R163  2      Robert, Rupert
      S530  4      Smith, Smyth, Schmidt, Schmitt
      3 groups, 9 names
    TEXT
    expect(io.file_reads).to eq(%w[f g])
  end

  it "groups by MRA key equality and honors minimum boundaries and distinct names" do
    io.files["f"] = "Byrne\nBoern\n".b
    mra = Namesound::GroupCommand.run(%w[mra f], Set.new, {}, inputs)

    expect(mra.code).to eq(1)
    expect(mra.out).to eq("0 groups, 0 names\n")

    io.files["f"] = "Robert\nRobert\n".b
    singleton = Namesound::GroupCommand.run(
      %w[soundex f], Set.new, { "--min" => "1" }, Namesound::Inputs.new(io)
    )

    expect(singleton.code).to eq(0)
    expect(singleton.out).to eq("KEY   COUNT  NAMES\nR163  1      Robert\n1 group, 1 name\n")

    io.files["f"] = "Robert\nRupert\n".b
    upper = Namesound::GroupCommand.run(
      %w[soundex f], Set.new, { "--min" => "99" }, Namesound::Inputs.new(io)
    )

    expect(upper.code).to eq(1)
    expect(upper.out).to eq("0 groups, 0 names\n")

    io.files["f"] = +""
    empty = Namesound::GroupCommand.run(
      %w[soundex f], Set.new, { "--min" => "5" }, Namesound::Inputs.new(io)
    )

    expect(empty.code).to eq(1)
    expect(empty.out).to eq("0 groups, 0 names\n")
  end

  it "renders all worked comparisons with normative Grid spacing and accepts a hyphen-leading name" do
    smith = Namesound::CompareCommand.run(%w[Smith Smyth], Set.new, {}, inputs)

    expect(smith.code).to eq(0)
    expect(smith.out).to eq(<<~TEXT)
      ALGORITHM  FIRST   SECOND  SAME
      soundex    S530    S530    yes
      refined    S38060  S38060  yes
      nysiis     SNAT    SNYT    no
      metaphone  SM0     SM0     yes
      cologne    862     862     yes
      mra        SMTH    SMYTH   yes
      agree: 5 of 6
    TEXT

    mra = Namesound::CompareCommand.run(%w[Byrne Boern], Set.new, { "--algorithm" => "MRA" }, inputs)

    expect(mra.code).to eq(0)
    expect(mra.out).to eq(<<~TEXT)
      ALGORITHM  FIRST  SECOND  SAME
      mra        BYRN   BRN     yes
      agree: 1 of 1
    TEXT

    no_agreement = Namesound::CompareCommand.run(%w[Hello 1234], Set.new, {}, inputs)

    expect(no_agreement.code).to eq(1)
    expect(no_agreement.out).to eq(<<~TEXT)
      ALGORITHM  FIRST  SECOND  SAME
      soundex    H400   -       no
      refined    H070   -       no
      nysiis     HAL    -       no
      metaphone  HL     -       no
      cologne    05     -       no
      mra        HL     -       no
      agree: 0 of 6
    TEXT

    hyphen_leading = Namesound::CompareCommand.run(["-Robert", "Rupert"], Set.new, { "--algorithm" => "soundex" },
                                                   inputs)

    expect(hyphen_leading.code).to eq(0)
    expect(hyphen_leading.out).to eq(
      "ALGORITHM  FIRST  SECOND  SAME\nsoundex    R163   R163    yes\nagree: 1 of 1\n"
    )
  end

  it "raises direct unprefixed validation failures before any file reads" do
    cases = [
      [Namesound::AlgorithmsCommand, ["extra"], Set.new, {}, "too many arguments"],
      [Namesound::KeyCommand, [], Set.new, {}, "missing ALGORITHM"],
      [Namesound::KeyCommand, ["soundex"], Set.new, {}, "missing FILE"],
      [Namesound::KeyCommand, %w[soundex f g], Set.new, {}, "too many arguments"],
      [Namesound::KeyCommand, %w[soundx f], Set.new, {}, "unknown algorithm \"soundx\""],
      [Namesound::GroupCommand, [], Set.new, {}, "missing ALGORITHM"],
      [Namesound::GroupCommand, ["soundex"], Set.new, {}, "missing FILE"],
      [Namesound::GroupCommand, %w[nope f], Set.new, { "--min" => "0" }, "unknown algorithm \"nope\""],
      [
        Namesound::GroupCommand,
        %w[soundex f],
        Set.new,
        { "--min" => "0" },
        "invalid --min \"0\" (expected 1 to 99)"
      ],
      [Namesound::GroupCommand, ["soundex"], Set.new, { "--min" => "0" }, "missing FILE"],
      [Namesound::CompareCommand, [], Set.new, {}, "missing NAME"],
      [Namesound::CompareCommand, ["a"], Set.new, {}, "missing NAME"],
      [Namesound::CompareCommand, %w[a b c], Set.new, {}, "too many arguments"],
      [
        Namesound::CompareCommand,
        %w[a b],
        Set.new,
        { "--algorithm" => "nope" },
        "unknown algorithm \"nope\""
      ]
    ]

    cases.each do |command, args, flags, values, message|
      expect { command.run(args, flags, values, inputs) }.to raise_error(Namesound::Failure, message)
    end

    expect(io.file_reads).to eq([])
  end
end
