<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# namesound

namesound is an offline Ruby command-line tool for people who clean lists of people's names (customers, members, genealogy records) and need to see which spellings sound alike. It turns names into phonetic keys with six algorithms, groups the names of a file that share a key and compares two names under every algorithm. It works locally and needs no network connection.

[![CI](https://github.com/Gulliby-development/namesound/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/namesound/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Why

`Robert` and `Rupert`, or `Smith`, `Smyth` and `Schmidt`, are different strings but sound alike, so a plain text match misses the duplicates in a list. A phonetic key turns each of them into the same short code, so `namesound group` lists the spellings that belong together and `namesound compare` shows how two names fare under every algorithm.

## Install

Use Ruby 3.4 and Bundler. From the project directory, install the development dependencies with `bundle install`. Run the program as `ruby exe/namesound COMMAND`. In the examples below, `namesound` means `ruby exe/namesound`; the CLI is platform-neutral, while the setup snippets use POSIX `sh` syntax.

## Usage

```text
usage: namesound algorithms
       namesound key [--bare] ALGORITHM FILE
       namesound group [--min N] [--sort ORDER] ALGORITHM FILE...
       namesound compare [--algorithm NAME] NAME1 NAME2
```

Each example that reads a file creates it first. `compare` takes names as arguments and `algorithms` takes no arguments.

### Key example

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

The exit code is 1 here because `1234` has no key. `--bare` writes the keys only, one per line.

### Group example

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

### Group order example

```sh
printf 'Robert\nRupert\nSmith\nSmyth\nSchmidt\nRubin\nMueller\nMiller\n' > names.txt
ruby exe/namesound group --sort count soundex names.txt
```

```text
KEY   COUNT  NAMES
S530  3      Smith, Smyth, Schmidt
M460  2      Mueller, Miller
R163  2      Robert, Rupert
3 groups, 7 names
```

### Compare example

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

### Algorithms example

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

## Commands

The available algorithms are `soundex` (American Soundex), `refined` (Refined Soundex), `nysiis` (cut at six characters), `metaphone`, `cologne` (German Cologne phonetics), and `mra` (Match Rating Approach codex). Algorithm names are ASCII case-insensitive, so names such as `SOUNDEX` and `Nysiis` are accepted.

- `algorithms` prints the algorithm table and takes no arguments.
- `key [--bare] ALGORITHM FILE` reads one file and prints each entry with its key. `--bare` prints only the keys. An entry with no key is shown as `-` (or as an empty line in bare mode); any such entry makes the command return code 1.
- `group [--min N] [--sort ORDER] ALGORITHM FILE...` reads all named files in argument order, removes duplicate entries by exact text, and groups distinct names by equal key. Entries without a key are omitted. The default minimum group size is 2; `N` must be an ASCII integer from 1 through 99. Groups are ordered by key, or with `--sort count` by size, largest first and equal sizes by key; `--sort key` is the default and any other order is an error. The names of a group retain first-appearance order. For `mra`, groups use equal codex keys.
- `compare [--algorithm NAME] NAME1 NAME2` compares the two names under all six algorithms, or only the selected algorithm. Non-MRA algorithms agree when both keys are nonempty and equal. MRA compares codices using Match Rating rules; it does not require the codices to be identical. Names are arguments rather than file paths.

Input files must contain valid UTF-8. Entries are separated by LF; a CR immediately before LF (or at end of file) is removed, then only spaces and tabs at the ends are trimmed. Empty entries are ignored. A file argument of `-` reads standard input; standard input may be named only once.

### Options

| Option | Command | Description |
|---|---|---|
| `--bare` | `key` | Write the keys only, one per line |
| `--min N` or `--min=N` | `group` | Least number of names a group needs, 1 to 99 (default 2) |
| `--sort ORDER` or `--sort=ORDER` | `group` | `key` (default) or `count`: largest groups first |
| `--algorithm NAME` or `--algorithm=NAME` | `compare` | Compare under one algorithm only |

## Exit codes

- `0`: success. For `compare`, at least one algorithm agrees.
- `1`: a negative result: a `key` entry has no key, `group` finds no group, or `compare` finds no agreeing algorithm.
- `2`: an error, such as invalid input, an unknown command or algorithm, invalid options, a missing argument, or an unreadable file. Errors leave standard output empty and write one line to standard error.

## Development

Run the automated specs with `bundle exec rspec` and check style with `bundle exec rubocop`.

## License

MIT, see [LICENSE](LICENSE).

---

Built with BAKED
