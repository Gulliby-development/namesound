# frozen_string_literal: true

require "open3"
require "rbconfig"
require_relative "../../lib/namesound/cmd/cli"

RSpec.describe Namesound::Cli do
  let(:io) do
    Class.new do
      attr_accessor :stdin_bytes
      attr_reader :events, :files, :file_errors, :runtime_error_paths

      def initialize
        @stdin_bytes = +""
        @events = []
        @files = {}
        @file_errors = []
        @runtime_error_paths = []
      end

      def read_stdin
        @events << [:read_stdin]
        @stdin_bytes
      end

      def read_file(path)
        @events << [:read_file, path]
        raise IOError if @file_errors.include?(path)
        raise "programming defect" if @runtime_error_paths.include?(path)

        @files.fetch(path)
      end

      def out(text)
        @events << [:out, text]
      end

      def err(text)
        @events << [:err, text]
      end
    end.new
  end

  it "handles missing invocation, argument UTF-8, help, and unknown commands" do
    expect(described_class.run([], io)).to eq(2)
    expect(io.events).to eq([[:err, "namesound: missing command (algorithms, key, group or compare)\n"]])

    io.events.clear
    expect(described_class.run(["show", "\xFF".b.force_encoding(Encoding::UTF_8)], io)).to eq(2)
    expect(io.events).to eq([[:err, "namesound: argument is not valid UTF-8\n"]])

    io.events.clear
    expect(described_class.run(["--help"], io)).to eq(0)
    expect(io.events).to eq(
      [[:out, "usage: namesound algorithms\n       " \
              "namesound key [--bare] ALGORITHM FILE\n       " \
              "namesound group [--min N] ALGORITHM FILE...\n       " \
              "namesound compare [--algorithm NAME] NAME1 NAME2\n"]]
    )

    io.events.clear
    expect(described_class.run(["show"], io)).to eq(2)
    expect(io.events).to eq([[:err, "namesound: unknown command \"show\"\n"]])

    io.events.clear
    expect(described_class.run(["--help", "x"], io)).to eq(2)
    expect(io.events).to eq([[:err, "namesound: unknown command \"--help\"\n"]])
  end

  it "runs key, group, and comparison examples through the CLI" do
    io.files["key_table"] =
      "Robert\nRupert\nRubin\nSmith\nSmyth\nSchmidt\nSchmitt\nMueller\nMüller\nMiller\n1234\n  Smith \nSmith\n".b
    io.files["key_bare"] = "Robert\n1234\nRupert\n".b
    io.files["aha"] = "Aha\n".b
    io.files["group_first"] = "Robert\nRupert\nSmith\nSmyth\nMueller\n".b
    io.files["group_second"] = "Müller\nMiller\nSchmidt\nSchmitt\nSmith\n1234\nRubin\n".b
    io.files["single"] = "Robert\nRobert\n".b

    [
      [
        %w[key SOUNDEX key_table],
        1,
        [
          [:read_file, "key_table"],
          [:out, "NAME     KEY\nRobert   R163\nRupert   R163\nRubin    R150\nSmith    S530\nSmyth    S530\n" \
                 "Schmidt  S530\nSchmitt  S530\nMueller  M460\nM?ller   M460\nMiller   M460\n" \
                 "1234     -\nSmith    S530\nSmith    S530\n"]
        ]
      ],
      [
        %w[key --bare --bare soundex key_bare],
        1,
        [[:read_file, "key_bare"], [:out, "R163\n\nR163\n"]]
      ],
      [%w[key soundex -], 0, [[:read_stdin]]],
      [
        %w[key Nysiis aha],
        0,
        [[:read_file, "aha"], [:out, "NAME  KEY\nAha   AH\n"]]
      ],
      [
        %w[group soundex group_first group_second],
        0,
        [
          [:read_file, "group_first"],
          [:read_file, "group_second"],
          [:out, "KEY   COUNT  NAMES\nM460  3      Mueller, M?ller, Miller\nR163  2      Robert, Rupert\n" \
                 "S530  4      Smith, Smyth, Schmidt, Schmitt\n3 groups, 9 names\n"]
        ]
      ],
      [%w[group mra group_first], 1, [[:read_file, "group_first"], [:out, "0 groups, 0 names\n"]]],
      [
        %w[compare Smith Smyth],
        0,
        [
          [:out, "ALGORITHM  FIRST   SECOND  SAME\nsoundex    S530    S530    yes\nrefined    S38060  S38060  yes\n" \
                 "nysiis     SNAT    SNYT    no\nmetaphone  SM0     SM0     yes\ncologne    862     862     yes\n" \
                 "mra        SMTH    SMYTH   yes\nagree: 5 of 6\n"]
        ]
      ],
      [
        %w[compare --algorithm MRA Byrne Boern],
        0,
        [[:out, "ALGORITHM  FIRST  SECOND  SAME\nmra        BYRN   BRN     yes\nagree: 1 of 1\n"]]
      ],
      [
        %w[compare Hello 1234],
        1,
        [
          [:out, "ALGORITHM  FIRST  SECOND  SAME\nsoundex    H400   -       no\nrefined    H070   -       no\n" \
                 "nysiis     HAL    -       no\nmetaphone  HL     -       no\ncologne    05     -       no\n" \
                 "mra        HL     -       no\nagree: 0 of 6\n"]
        ]
      ],
      [
        ["compare", "--algorithm", "soundex", "-Robert", "Rupert"],
        0,
        [[:out, "ALGORITHM  FIRST  SECOND  SAME\nsoundex    R163   R163    yes\nagree: 1 of 1\n"]]
      ],
      [
        ["group", "--min=0", "--min", "1", "soundex", "single"],
        0,
        [
          [:read_file, "single"],
          [:out, "KEY   COUNT  NAMES\nR163  1      Robert\n1 group, 1 name\n"]
        ]
      ]
    ].each do |arguments, code, expected_events|
      io.events.clear
      expect([described_class.run(arguments, io), io.events]).to eq([code, expected_events])
    end
  end

  it "reports ordered command, option, count, algorithm, and minimum diagnostics" do
    io.files["f"] = "Robert\n".b

    [
      [%w[algorithms extra], "namesound: too many arguments\n"],
      [%w[key], "namesound: missing ALGORITHM\n"],
      [%w[key soundex], "namesound: missing FILE\n"],
      [%w[key soundex f g], "namesound: too many arguments\n"],
      [%w[group], "namesound: missing ALGORITHM\n"],
      [%w[group soundex], "namesound: missing FILE\n"],
      [%w[compare], "namesound: missing NAME\n"],
      [%w[compare a], "namesound: missing NAME\n"],
      [%w[compare a b c], "namesound: too many arguments\n"],
      [%w[key soundx f], "namesound: unknown algorithm \"soundx\"\n"],
      [%w[compare --algorithm nope a b], "namesound: unknown algorithm \"nope\"\n"],
      [%w[key --bare=1 soundex f], "namesound: unknown option \"--bare=1\"\n"],
      [%w[compare --bare a b], "namesound: unknown option \"--bare\"\n"],
      [%w[algorithms --help], "namesound: unknown option \"--help\"\n"],
      [%w[key -- soundex f], "namesound: unknown option \"--\"\n"],
      [%w[group --min], "namesound: --min needs a value\n"],
      [
        %w[group --min --bare soundex f],
        "namesound: invalid --min \"--bare\" (expected 1 to 99)\n"
      ],
      [
        %w[group --min=0 nope f],
        "namesound: unknown algorithm \"nope\"\n"
      ],
      [%w[group --min=0 soundex], "namesound: missing FILE\n"],
      [%w[key --bad], "namesound: unknown option \"--bad\"\n"],
      [
        %w[group --min=0 soundex f],
        "namesound: invalid --min \"0\" (expected 1 to 99)\n"
      ],
      [
        %w[group --min=07 soundex f],
        "namesound: invalid --min \"07\" (expected 1 to 99)\n"
      ],
      [
        %w[group --min=100 soundex f],
        "namesound: invalid --min \"100\" (expected 1 to 99)\n"
      ],
      [
        ["group", "--min=", "soundex", "f"],
        "namesound: invalid --min \"\" (expected 1 to 99)\n"
      ],
      [
        ["group", "--min=٥", "soundex", "f"],
        "namesound: invalid --min \"?\" (expected 1 to 99)\n"
      ],
      [
        ["group", "--min", "5\n", "soundex", "f"],
        "namesound: invalid --min \"5?\" (expected 1 to 99)\n"
      ]
    ].each do |arguments, error_text|
      io.events.clear
      expect([described_class.run(arguments, io), io.events]).to eq([2, [[:err, error_text]]])
    end
  end

  it "translates failed reads and malformed sources into one error without output" do
    io.file_errors.push("nofile", "café")
    io.files["f"] = "Robert\nRupert\n".b
    io.files["g"] = "a\xFF\n".b

    [
      [
        %w[key soundex nofile],
        "Robert\n".b,
        [[:read_file, "nofile"], [:err, "namesound: nofile: cannot read the file\n"]]
      ],
      [
        %w[key soundex café],
        "Robert\n".b,
        [[:read_file, "café"], [:err, "namesound: caf?: cannot read the file\n"]]
      ],
      [
        %w[group soundex f nofile],
        "Robert\n".b,
        [
          [:read_file, "f"],
          [:read_file, "nofile"],
          [:err, "namesound: nofile: cannot read the file\n"]
        ]
      ],
      [
        %w[group soundex - -],
        "Robert\n".b,
        [[:read_stdin], [:err, "namesound: standard input is named twice\n"]]
      ],
      [
        %w[key soundex g],
        "Robert\n".b,
        [[:read_file, "g"], [:err, "namesound: g: input is not valid UTF-8\n"]]
      ],
      [
        %w[key soundex -],
        "a\xFF\n".b,
        [[:read_stdin], [:err, "namesound: <stdin>: input is not valid UTF-8\n"]]
      ]
    ].each do |arguments, stdin_bytes, expected_events|
      io.events.clear
      io.stdin_bytes = stdin_bytes
      expect([described_class.run(arguments, io), io.events]).to eq([2, expected_events])
    end
  end

  it "reads repeated files again and waits for every read before group output" do
    io.files["f"] = "Robert\nRupert\n".b

    expect(described_class.run(%w[group soundex f f], io)).to eq(0)
    expect(io.events).to eq(
      [
        [:read_file, "f"],
        [:read_file, "f"],
        [:out, "KEY   COUNT  NAMES\nR163  2      Robert, Rupert\n1 group, 2 names\n"]
      ]
    )
  end

  it "lets unrelated runtime errors propagate without converting them to CLI failures" do
    io.runtime_error_paths << "f"

    expect { described_class.run(%w[key soundex f], io) }
      .to raise_error(RuntimeError, "programming defect")
    expect(io.events).to eq([[:read_file, "f"]])
  end

  it "reports malformed UTF-8 written to the real executable's standard input" do
    script = File.expand_path("../../exe/namesound", __dir__)
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      script,
      "key",
      "soundex",
      "-",
      stdin_data: "a\xFF\n".b,
      binmode: true
    )

    expect([status.exitstatus, stdout, stderr]).to eq([2, "".b, "namesound: <stdin>: input is not valid UTF-8\n".b])
  end
end
