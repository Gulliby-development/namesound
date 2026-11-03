# frozen_string_literal: true

require "open3"
require "tmpdir"

RSpec.describe "namesound key --unique" do
  let(:exe) { File.expand_path("../../exe/namesound", __dir__) }

  def run_key(text, *)
    Dir.mktmpdir("namesound") do |dir|
      path = File.join(dir, "names.txt")
      File.binwrite(path, text)
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, exe, "key", *, path, binmode: true)
      [status.exitstatus, stdout.b, stderr.b.gsub(path, "FILE")]
    end
  end

  it "keeps every entry without the option" do
    table = "NAME   KEY\nSmith  S530\nSmith  S530\n".b
    expect(run_key("Smith\nSmith\n", "soundex")).to eq([0, table, "".b])
  end

  it "skips an entry whose exact text appeared earlier" do
    table = "NAME   KEY\nSmith  S530\nSmyth  S530\nsmith  S530\n".b
    text = "Smith\nSmyth\nSmith\nsmith\n"
    expect(run_key(text, "--unique", "soundex")).to eq([0, table, "".b])
    expect(run_key(text, "soundex", "--unique")).to eq([0, table, "".b])
  end

  it "compares entries after the trimming of blanks and line ends" do
    table = "NAME   KEY\nSmith  S530\nSmyth  S530\n".b
    expect(run_key("Smith\r\n  Smyth \n\n\tSmith\n", "--unique", "soundex")).to eq([0, table, "".b])
  end

  it "combines with --bare and keeps an empty key as an empty line" do
    expect(run_key("Smith\n1234\nSmith\n1234\nRupert\n", "--bare", "--unique", "soundex")).to eq(
      [1, "S530\n\nR163\n".b, "".b]
    )
  end

  it "returns code 1 for a repeated entry without a key only once" do
    expect(run_key("1234\n1234\n", "--unique", "soundex")).to eq([1, "NAME  KEY\n1234  -\n".b, "".b])
  end

  it "is not an option of the other commands" do
    code, out, err = run_key("Smith\n", "--unique", "soundex").then { |r| r }
    expect(code).to eq(0)
    expect(out).to eq("NAME   KEY\nSmith  S530\n".b)
    expect(err).to eq("".b)

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, exe, "compare", "--unique", "a", "b", binmode: true)
    expect([status.exitstatus, stdout.b, stderr.b]).to eq([2, "".b, "namesound: unknown option \"--unique\"\n".b])
  end
end
