# frozen_string_literal: true

require_relative "../../lib/namesound/base/failure"
require_relative "../../lib/namesound/base/output"
require_relative "../../lib/namesound/base/text"
require_relative "../../lib/namesound/base/options"

RSpec.describe "Namesound base value types" do
  it "preserves the Failure and Output public contracts" do
    failure = Namesound::Failure.new("problem")
    expect(failure).to be_a(StandardError)
    expect(failure.message).to eq("problem")

    output = Namesound::Output.new("done\n", 1)
    expect(output.members).to eq(%i[out code])
    expect(output.out).to eq("done\n")
    expect(output.code).to eq(1)
  end
end

RSpec.describe Namesound::Text do
  it "sanitizes, quotes, folds and pluralizes literal strings" do
    [
      [:plain, ["A\"~\t\n\u0000é😀"], "A\"~?????"],
      [:show, ["a\"b\né"], "\"a\"b??\""],
      [:plain, [""], ""],
      [:show, [""], "\"\""],
      [:fold_ascii, ["AZazİıſKÉ"], "azazİıſKÉ"],
      [:plural, [1, "name"], "1 name"],
      [:plural, [0, "name"], "0 names"],
      [:plural, [2, "group"], "2 groups"]
    ].each do |method, arguments, expected|
      expect(described_class.public_send(method, *arguments)).to eq(expected)
    end
  end
end

RSpec.describe Namesound::Options do
  it "consumes and returns literal option cases in order" do
    [
      [
        ["x", "--bare", "--bare", "-", "-5"],
        Set["--bare"],
        Set["--min", "--algorithm"],
        Set["--bare"],
        {},
        ["x", "-", "-5"]
      ],
      [
        ["--min=2", "--min", "--bare", "--algorithm=a=b", "--algorithm="],
        Set["--bare"],
        Set["--min", "--algorithm"],
        Set[],
        { "--min" => "--bare", "--algorithm" => "" },
        []
      ],
      [
        ["--algorithm=a=b"],
        Set["--bare"],
        Set["--algorithm"],
        Set[],
        { "--algorithm" => "a=b" },
        []
      ],
      [[], Set["--bare"], Set["--min", "--algorithm"], Set[], {}, []]
    ].each do |argv, flags, valued, expected_flags, expected_settings, expected_args|
      parsed = described_class.parse(argv, flags, valued)
      expect([parsed.members, parsed.flags, parsed.settings, parsed.args]).to eq(
        [%i[flags settings args], expected_flags, expected_settings, expected_args]
      )
    end
  end

  it "raises the first literal option diagnostic" do
    [
      [["--min"], "--min needs a value"],
      [["--"], "unknown option \"--\""],
      [["--help"], "unknown option \"--help\""],
      [["--bare=1"], "unknown option \"--bare=1\""],
      [["--é\n", "--min"], "unknown option \"--??\""]
    ].each do |argv, expected_message|
      expect do
        described_class.parse(argv, Set["--bare"], Set["--min"])
      end.to raise_error(Namesound::Failure, expected_message)
    end
  end
end
