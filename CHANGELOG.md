# Change Log

## [Unreleased](https://github.com/theodi/csvlint.rb/tree/HEAD)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.2...HEAD)

**Merged pull requests:**

- Error reporting schema expanded test suite [\#138](https://github.com/theodi/csvlint.rb/pull/138) ([quadrophobiac](https://github.com/quadrophobiac))

- Validate header size improvement [\#137](https://github.com/theodi/csvlint.rb/pull/137) ([adamc00](https://github.com/adamc00))

- Invalid schema [\#132](https://github.com/theodi/csvlint.rb/pull/132) ([bcouston](https://github.com/bcouston))

## [0.1.2](https://github.com/theodi/csvlint.rb/tree/0.1.2) (2015-07-15)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.1...0.1.2)

**Closed issues:**

- When an encoding error is thrown the line content is put into the column field in the error object [\#131](https://github.com/theodi/csvlint.rb/issues/131)

**Merged pull requests:**

- Catch invalid URIs [\#133](https://github.com/theodi/csvlint.rb/pull/133) ([pezholio](https://github.com/pezholio))

- Emit a warning when the CSV header does not match the supplied schema [\#127](https://github.com/theodi/csvlint.rb/pull/127) ([adamc00](https://github.com/adamc00))

## [0.1.1](https://github.com/theodi/csvlint.rb/tree/0.1.1) (2015-07-13)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.0...0.1.1)

**Closed issues:**

- Add Command Line Support [\#128](https://github.com/theodi/csvlint.rb/issues/128)

- BUG: Incorrect inconsistent\_values error on numeric columns [\#106](https://github.com/theodi/csvlint.rb/issues/106)

**Merged pull requests:**

- Fixes line content incorrectly being put into the row column field when there is an encoding error. [\#130](https://github.com/theodi/csvlint.rb/pull/130) ([glacier](https://github.com/glacier))

- Add command line help [\#129](https://github.com/theodi/csvlint.rb/pull/129) ([pezholio](https://github.com/pezholio))

- Remove stray q character. [\#125](https://github.com/theodi/csvlint.rb/pull/125) ([adamc00](https://github.com/adamc00))

- csvlint utility can take arguments to specify a schema and pp errors [\#124](https://github.com/theodi/csvlint.rb/pull/124) ([adamc00](https://github.com/adamc00))

- Fixed warning - use expect\( \) rather than .should [\#123](https://github.com/theodi/csvlint.rb/pull/123) ([jezhiggins](https://github.com/jezhiggins))

- Fixed spelling mistake [\#121](https://github.com/theodi/csvlint.rb/pull/121) ([jezhiggins](https://github.com/jezhiggins))

- Avoid using \#blank? if unnecessary [\#120](https://github.com/theodi/csvlint.rb/pull/120) ([jpmckinney](https://github.com/jpmckinney))

- eliminate some date and time formats, related \#105 [\#119](https://github.com/theodi/csvlint.rb/pull/119) ([jpmckinney](https://github.com/jpmckinney))

- Match another CSV error about line endings [\#118](https://github.com/theodi/csvlint.rb/pull/118) ([jpmckinney](https://github.com/jpmckinney))

- fixed typo mistake in README [\#117](https://github.com/theodi/csvlint.rb/pull/117) ([railsfactory-kumaresan](https://github.com/railsfactory-kumaresan))

- Integrate @jpmickinney's build\_formats improvements [\#112](https://github.com/theodi/csvlint.rb/pull/112) ([Floppy](https://github.com/Floppy))

- make limit\_lines into a non-dialect option [\#110](https://github.com/theodi/csvlint.rb/pull/110) ([Floppy](https://github.com/Floppy))

- fix coveralls stats [\#109](https://github.com/theodi/csvlint.rb/pull/109) ([Floppy](https://github.com/Floppy))

- Speed up \#build\_formats \(changes its API\) [\#103](https://github.com/theodi/csvlint.rb/pull/103) ([jpmckinney](https://github.com/jpmckinney))

- Limit lines [\#101](https://github.com/theodi/csvlint.rb/pull/101) ([Hoedic](https://github.com/Hoedic))

## [0.1.0](https://github.com/theodi/csvlint.rb/tree/0.1.0) (2014-11-27)

**Implemented enhancements:**

- Blank values shouldn't count as inconsistencies [\#90](https://github.com/theodi/csvlint.rb/issues/90)

- Make sure we don't check schema column count and ragged row count together [\#66](https://github.com/theodi/csvlint.rb/issues/66)

- Include the failed constraints in error message when doing field validation [\#64](https://github.com/theodi/csvlint.rb/issues/64)

- Include the column value in error message when field validation fails [\#63](https://github.com/theodi/csvlint.rb/issues/63)

- Expose optional JSON table schema fields [\#55](https://github.com/theodi/csvlint.rb/issues/55)

- Ensure header rows are properly handled and validated [\#48](https://github.com/theodi/csvlint.rb/issues/48)

- Support zipped CSV? [\#30](https://github.com/theodi/csvlint.rb/issues/30)

- Improve feedback on inconsistent values [\#29](https://github.com/theodi/csvlint.rb/issues/29)

- Reported error positions are not massively useful [\#15](https://github.com/theodi/csvlint.rb/issues/15)

**Fixed bugs:**

- undefined method `\[\]' for nil:NilClass from fetch\_error [\#71](https://github.com/theodi/csvlint.rb/issues/71)

- Inconsistent column bases [\#69](https://github.com/theodi/csvlint.rb/issues/69)

- Improve error handling in Schema loading [\#42](https://github.com/theodi/csvlint.rb/issues/42)

- Recover from some line ending problems [\#41](https://github.com/theodi/csvlint.rb/issues/41)

- Inconsistent values due to number format differences [\#32](https://github.com/theodi/csvlint.rb/issues/32)

- New lines in quoted fields are valid [\#31](https://github.com/theodi/csvlint.rb/issues/31)

- Wrongly reporting incorrect file extension [\#23](https://github.com/theodi/csvlint.rb/issues/23)

- Incorrect extension reported when URL has query options at the end [\#14](https://github.com/theodi/csvlint.rb/issues/14)

**Closed issues:**

- Get gem continuously deploying [\#93](https://github.com/theodi/csvlint.rb/issues/93)

- Publish on rubygems.org [\#92](https://github.com/theodi/csvlint.rb/issues/92)

- Duplicate column names [\#87](https://github.com/theodi/csvlint.rb/issues/87)

- Return code is always 0 \(except when it isn't\) [\#85](https://github.com/theodi/csvlint.rb/issues/85)

- Can't pipe data to csvlint [\#84](https://github.com/theodi/csvlint.rb/issues/84)

- They have some validator running if someone wants to inspect it for "inspiration" [\#27](https://github.com/theodi/csvlint.rb/issues/27)

- Allow CSV parsing options to be configured as a parameter [\#6](https://github.com/theodi/csvlint.rb/issues/6)

- Use explicit CSV parsing options [\#5](https://github.com/theodi/csvlint.rb/issues/5)

- Improving encoding detection [\#2](https://github.com/theodi/csvlint.rb/issues/2)

**Merged pull requests:**

- Continuously deploy gem [\#102](https://github.com/theodi/csvlint.rb/pull/102) ([pezholio](https://github.com/pezholio))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*