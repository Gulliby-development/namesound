# frozen_string_literal: true

RSpec.describe "README documentation" do
  let(:readme) { File.read(File.expand_path("../README.md", __dir__), encoding: "UTF-8") }

  it "documents installation, commands, exit codes, and development" do
    expect(readme).to include(
      "## Install",
      "bundle install",
      "ruby exe/namesound COMMAND",
      "## Usage",
      "## Commands",
      "## Exit codes",
      "## Development",
      "bundle exec rspec",
      "bundle exec rubocop",
      "In the examples below, `namesound` means `ruby exe/namesound`"
    )
  end

  it "shows the exact four-line command usage in a fenced text block" do
    expect(readme).to include(<<~USAGE)
      ```text
      usage: namesound algorithms
             namesound key [--bare] ALGORITHM FILE
             namesound group [--min N] [--sort ORDER] ALGORITHM FILE...
             namesound compare [--algorithm NAME] NAME1 NAME2
      ```
    USAGE
  end

  it "pairs each runnable command example with its literal output" do
    expect(readme).to include(<<~'KEY_EXAMPLE')
      ```sh
      printf 'Robert\nRupert\nRubin\nSmith\nSmyth\nSchmidt\nSchmitt\nMueller\nM\303\274ller\nMiller\n1234\n  Smith \nSmith\n' > names.txt
      ruby exe/namesound key soundex names.txt
      ```

      ```text
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
      ```
    KEY_EXAMPLE

    expect(readme).to include(<<~'GROUP_EXAMPLE')
      ```sh
      printf 'Robert\nRupert\nRubin\nSmith\nSmyth\nSchmidt\nSchmitt\nMueller\nM\303\274ller\nMiller\n1234\n  Smith \nSmith\n' > names.txt
      ruby exe/namesound group soundex names.txt
      ```

      ```text
      KEY   COUNT  NAMES
      M460  3      Mueller, M?ller, Miller
      R163  2      Robert, Rupert
      S530  4      Smith, Smyth, Schmidt, Schmitt
      3 groups, 9 names
      ```
    GROUP_EXAMPLE

    expect(readme).to include(<<~COMPARE_EXAMPLE)
      ```sh
      ruby exe/namesound compare Smith Smyth
      ```

      ```text
      ALGORITHM  FIRST   SECOND  SAME
      soundex    S530    S530    yes
      refined    S38060  S38060  yes
      nysiis     SNAT    SNYT    no
      metaphone  SM0     SM0     yes
      cologne    862     862     yes
      mra        SMTH    SMYTH   yes
      agree: 5 of 6
      ```
    COMPARE_EXAMPLE

    expect(readme).to include(<<~ALGORITHMS_EXAMPLE)
      ```sh
      ruby exe/namesound algorithms
      ```

      ```text
      NAME       KEY         ABOUT
      soundex    4 chars     American Soundex
      refined    any length  Refined Soundex
      nysiis     6 chars     NYSIIS, cut at 6
      metaphone  any length  original Metaphone
      cologne    digits      Cologne phonetics (German)
      mra        6 chars     Match Rating Approach codex
      ```
    ALGORITHMS_EXAMPLE
  end

  it "does not expose code point placeholders in the examples" do
    expect(readme).not_to include("<U+")
  end
end
