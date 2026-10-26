# frozen_string_literal: true

require "open3"
require "tmpdir"

RSpec.describe "namesound group --sort" do
  let(:exe) { File.expand_path("../../exe/namesound", __dir__) }

  def run_group(*)
    Dir.mktmpdir("namesound") do |dir|
      path = File.join(dir, "names.txt")
      File.binwrite(path, "Robert\nRupert\nSmith\nSmyth\nSchmidt\nRubin\nMueller\nMiller\n")
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, exe, "group", *, path, binmode: true)
      [status.exitstatus, stdout.b, stderr.b.gsub(path, "FILE")]
    end
  end

  it "orders by key by default and for --sort key" do
    table = "KEY   COUNT  NAMES\nM460  2      Mueller, Miller\nR163  2      Robert, Rupert\n" \
            "S530  3      Smith, Smyth, Schmidt\n3 groups, 7 names\n".b
    expect(run_group("soundex")).to eq([0, table, "".b])
    expect(run_group("--sort", "key", "soundex")).to eq([0, table, "".b])
  end

  it "orders by count for --sort count and --sort=count" do
    table = "KEY   COUNT  NAMES\nS530  3      Smith, Smyth, Schmidt\nM460  2      Mueller, Miller\n" \
            "R163  2      Robert, Rupert\n3 groups, 7 names\n".b
    expect(run_group("--sort", "count", "soundex")).to eq([0, table, "".b])
    expect(run_group("--sort=count", "soundex")).to eq([0, table, "".b])
  end

  it "applies --min before --sort" do
    table = "KEY   COUNT  NAMES\nS530  3      Smith, Smyth, Schmidt\n1 group, 3 names\n".b
    expect(run_group("--min", "3", "--sort", "count", "soundex")).to eq([0, table, "".b])
  end

  it "rejects an unknown order with exit 2" do
    expect(run_group("--sort", "name", "soundex")).to eq(
      [2, "".b, "namesound: invalid --sort \"name\" (expected key or count)\n".b]
    )
  end

  it "rejects an empty order and a missing value with exit 2" do
    expect(run_group("--sort=", "soundex")).to eq(
      [2, "".b, "namesound: invalid --sort \"\" (expected key or count)\n".b]
    )
    expect(run_group("soundex", "--sort")[0..1]).to eq([2, "".b])
  end

  it "does not offer --sort to the other commands" do
    expect(run_group("soundex")[0]).to eq(0)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, exe, "key", "--sort", "count", "soundex", "x",
                                            binmode: true)
    expect([status.exitstatus, stdout.b, stderr.b]).to eq([2, "".b, "namesound: unknown option \"--sort\"\n".b])
  end
end
