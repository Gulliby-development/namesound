# frozen_string_literal: true

require_relative "../../lib/namesound/report/key_report"
require_relative "../../lib/namesound/report/group_report"
require_relative "../../lib/namesound/report/compare_report"

RSpec.describe "Namesound report renderers" do
  let(:group_record) { Struct.new(:key, :names) }

  it "renders the worked key table and its table edge cases" do
    [
      [
        [
          %w[Robert Rupert Rubin Smith Smyth Schmidt Schmitt Mueller Müller Miller 1234 Smith Smith],
          ["R163", "R163", "R150", "S530", "S530", "S530", "S530", "M460", "M460", "M460", "", "S530", "S530"],
          false
        ],
        ["NAME     KEY\n\
Robert   R163\n\
Rupert   R163\n\
Rubin    R150\n\
Smith    S530\n\
Smyth    S530\n\
Schmidt  S530\n\
Schmitt  S530\n\
Mueller  M460\n\
M?ller   M460\n\
Miller   M460\n\
1234     -\n\
Smith    S530\n\
Smith    S530\n", 1]
      ],
      [
        [%w[Robert Rupert], %w[R163 R163], false],
        ["NAME    KEY\nRobert  R163\nRupert  R163\n", 0]
      ],
      [
        [["1234"], [""], false],
        ["NAME  KEY\n1234  -\n", 1]
      ]
    ].each do |arguments, expected|
      result = Namesound::KeyReport.render(*arguments)
      expect([result.out, result.code]).to eq(expected)
    end
  end

  it "renders bare keys including empty-key lines" do
    [
      [%w[Robert 1234 Rupert], ["R163", "", "R163"], true, "R163\n\nR163\n", 1],
      [["1234"], [""], true, "\n", 1],
      [["Robert"], ["R163"], true, "R163\n", 0]
    ].each do |entries, keys, bare, expected_out, expected_code|
      result = Namesound::KeyReport.render(entries, keys, bare)
      expect([result.out, result.code]).to eq([expected_out, expected_code])
    end
  end

  it "returns empty output and success for empty key inputs in either mode" do
    [
      [[], [], false, "", 0],
      [[], [], true, "", 0]
    ].each do |entries, keys, bare, expected_out, expected_code|
      result = Namesound::KeyReport.render(entries, keys, bare)
      expect([result.out, result.code]).to eq([expected_out, expected_code])
    end
  end

  it "renders the worked group table and totals" do
    groups = [
      group_record.new("M460", %w[Mueller Müller Miller]),
      group_record.new("R163", %w[Robert Rupert]),
      group_record.new("S530", %w[Smith Smyth Schmidt Schmitt])
    ]

    result = Namesound::GroupReport.render(groups)

    expect([result.out, result.code]).to eq(
      ["KEY   COUNT  NAMES\n\
M460  3      Mueller, M?ller, Miller\n\
R163  2      Robert, Rupert\n\
S530  4      Smith, Smyth, Schmidt, Schmitt\n\
3 groups, 9 names\n", 0]
    )
  end

  it "renders group totals with singular forms and preserves supplied group order" do
    [
      [
        [],
        "0 groups, 0 names\n",
        1
      ],
      [
        [group_record.new("R163", ["Robert"])],
        "KEY   COUNT  NAMES\nR163  1      Robert\n1 group, 1 name\n",
        0
      ],
      [
        [group_record.new("R163", %w[Rupert Robert]), group_record.new("M460", ["Miller"])],
        "KEY   COUNT  NAMES\nR163  2      Rupert, Robert\nM460  1      Miller\n2 groups, 3 names\n",
        0
      ],
      [
        [group_record.new("R163", %w[Robert Rupert])],
        "KEY   COUNT  NAMES\nR163  2      Robert, Rupert\n1 group, 2 names\n",
        0
      ]
    ].each do |groups, expected_out, expected_code|
      result = Namesound::GroupReport.render(groups)
      expect([result.out, result.code]).to eq([expected_out, expected_code])
    end
  end

  it "renders the three worked comparison reports" do
    [
      [
        [
          Namesound::CompareReport::Row.new("soundex", "S530", "S530", true),
          Namesound::CompareReport::Row.new("refined", "S38060", "S38060", true),
          Namesound::CompareReport::Row.new("nysiis", "SNAT", "SNYT", false),
          Namesound::CompareReport::Row.new("metaphone", "SM0", "SM0", true),
          Namesound::CompareReport::Row.new("cologne", "862", "862", true),
          Namesound::CompareReport::Row.new("mra", "SMTH", "SMYTH", true)
        ],
        ["ALGORITHM  FIRST   SECOND  SAME\n\
soundex    S530    S530    yes\n\
refined    S38060  S38060  yes\n\
nysiis     SNAT    SNYT    no\n\
metaphone  SM0     SM0     yes\n\
cologne    862     862     yes\n\
mra        SMTH    SMYTH   yes\n\
agree: 5 of 6\n", 0]
      ],
      [
        [Namesound::CompareReport::Row.new("mra", "BYRN", "BRN", true)],
        ["ALGORITHM  FIRST  SECOND  SAME\nmra        BYRN   BRN     yes\nagree: 1 of 1\n", 0]
      ],
      [
        [
          Namesound::CompareReport::Row.new("soundex", "H400", "", false),
          Namesound::CompareReport::Row.new("refined", "H070", "", false),
          Namesound::CompareReport::Row.new("nysiis", "HAL", "", false),
          Namesound::CompareReport::Row.new("metaphone", "HL", "", false),
          Namesound::CompareReport::Row.new("cologne", "05", "", false),
          Namesound::CompareReport::Row.new("mra", "HL", "", false)
        ],
        ["ALGORITHM  FIRST  SECOND  SAME\n\
soundex    H400   -       no\n\
refined    H070   -       no\n\
nysiis     HAL    -       no\n\
metaphone  HL     -       no\n\
cologne    05     -       no\n\
mra        HL     -       no\n\
agree: 0 of 6\n", 1]
      ]
    ].each do |rows, expected|
      result = Namesound::CompareReport.render(rows)
      expect([result.out, result.code]).to eq(expected)
    end
  end

  it "defines the comparison row with the public member contract" do
    expect(Namesound::CompareReport::Row.members).to eq(%i[algorithm first_key second_key same])
  end

  it "keeps comparison headers, empty-key dashes, ordering, and supplied decisions" do
    [
      [
        [],
        ["ALGORITHM  FIRST  SECOND  SAME\nagree: 0 of 0\n", 1]
      ],
      [
        [
          Namesound::CompareReport::Row.new("mra", "", "", false),
          Namesound::CompareReport::Row.new("soundex", "", "R163", false)
        ],
        ["ALGORITHM  FIRST  SECOND  SAME\n\
mra        -      -       no\n\
soundex    -      R163    no\n\
agree: 0 of 2\n", 1]
      ],
      [
        [Namesound::CompareReport::Row.new("soundex", "R163", "R163", false)],
        ["ALGORITHM  FIRST  SECOND  SAME\nsoundex    R163   R163    no\nagree: 0 of 1\n", 1]
      ]
    ].each do |rows, expected|
      result = Namesound::CompareReport.render(rows)
      expect([result.out, result.code]).to eq(expected)
    end
  end

  it "sanitizes key and group names without escaping ASCII quotes" do
    name = "A\"B\t\n\u0000é😀"
    key_result = Namesound::KeyReport.render([name], ["A100"], false)
    group_result = Namesound::GroupReport.render([group_record.new("A100", [name, "A"])])

    expect([key_result.out, key_result.code]).to eq(["NAME      KEY\nA\"B?????  A100\n", 0])
    expect([group_result.out, group_result.code]).to eq(
      ["KEY   COUNT  NAMES\nA100  2      A\"B?????, A\n1 group, 2 names\n", 0]
    )
  end
end
