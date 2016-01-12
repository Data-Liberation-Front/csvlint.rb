# Change Log

## [0.3.0](https://github.com/theodi/csvlint.rb/tree/0.3.0) (2016-01-12)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.6...0.3.0)

**Merged pull requests:**

- still increment current\_line after invalid\_encoding error [\#174](https://github.com/theodi/csvlint.rb/pull/174) ([wjordan213](https://github.com/wjordan213))

- Support for CSV on the Web transformations [\#173](https://github.com/theodi/csvlint.rb/pull/173) ([JeniT](https://github.com/JeniT))

## [0.2.6](https://github.com/theodi/csvlint.rb/tree/0.2.6) (2015-11-16)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.5...0.2.6)

## [0.2.5](https://github.com/theodi/csvlint.rb/tree/0.2.5) (2015-11-16)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.4...0.2.5)

**Merged pull requests:**

- Use STDIN instead of ARGF [\#169](https://github.com/theodi/csvlint.rb/pull/169) ([pezholio](https://github.com/pezholio))

## [0.2.4](https://github.com/theodi/csvlint.rb/tree/0.2.4) (2015-10-20)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.3...0.2.4)

**Merged pull requests:**

- Fixes for CLI [\#164](https://github.com/theodi/csvlint.rb/pull/164) ([pezholio](https://github.com/pezholio))

## [0.2.3](https://github.com/theodi/csvlint.rb/tree/0.2.3) (2015-10-20)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.2...0.2.3)

**Closed issues:**

- Include field name with error [\#161](https://github.com/theodi/csvlint.rb/issues/161)

- Refactor the binary [\#150](https://github.com/theodi/csvlint.rb/issues/150)

**Merged pull requests:**

- Refactor CLI [\#163](https://github.com/theodi/csvlint.rb/pull/163) ([pezholio](https://github.com/pezholio))

- Update schema file example to clarify type [\#162](https://github.com/theodi/csvlint.rb/pull/162) ([wachunga](https://github.com/wachunga))

## [0.2.2](https://github.com/theodi/csvlint.rb/tree/0.2.2) (2015-10-09)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.1...0.2.2)

**Closed issues:**

- Eliminate some date and time formats \(for speed\) [\#105](https://github.com/theodi/csvlint.rb/issues/105)

**Merged pull requests:**

- Check characters in validate\_line method [\#160](https://github.com/theodi/csvlint.rb/pull/160) ([pezholio](https://github.com/pezholio))

- Further optimisations [\#159](https://github.com/theodi/csvlint.rb/pull/159) ([pezholio](https://github.com/pezholio))

- More optimizations after \#157 [\#158](https://github.com/theodi/csvlint.rb/pull/158) ([jpmckinney](https://github.com/jpmckinney))

- Memoize the result of CSV\#encode\_re [\#157](https://github.com/theodi/csvlint.rb/pull/157) ([jpmckinney](https://github.com/jpmckinney))

- Don't pass leading string to parse\_line [\#155](https://github.com/theodi/csvlint.rb/pull/155) ([pezholio](https://github.com/pezholio))

## [0.2.1](https://github.com/theodi/csvlint.rb/tree/0.2.1) (2015-10-07)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.2.0...0.2.1)

**Implemented enhancements:**

- Get total rows number about the CSV file that was validated [\#143](https://github.com/theodi/csvlint.rb/issues/143)

**Closed issues:**

- Optimization: Stream CSV [\#122](https://github.com/theodi/csvlint.rb/issues/122)

**Merged pull requests:**

- Add `row\_count` method [\#153](https://github.com/theodi/csvlint.rb/pull/153) ([pezholio](https://github.com/pezholio))

- Streaming validation [\#146](https://github.com/theodi/csvlint.rb/pull/146) ([pezholio](https://github.com/pezholio))

## [0.2.0](https://github.com/theodi/csvlint.rb/tree/0.2.0) (2015-10-05)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.4...0.2.0)

**Closed issues:**

- CSV on the web support [\#141](https://github.com/theodi/csvlint.rb/issues/141)

**Merged pull requests:**

- Recover from `ArgumentError`s when attempting to locate a schema and detect bad schema when JSON is malformed [\#152](https://github.com/theodi/csvlint.rb/pull/152) ([pezholio](https://github.com/pezholio))

- Catch errors if link headers are don't have particular values [\#151](https://github.com/theodi/csvlint.rb/pull/151) ([pezholio](https://github.com/pezholio))

- Rescue excel warning [\#149](https://github.com/theodi/csvlint.rb/pull/149) ([quadrophobiac](https://github.com/quadrophobiac))

- CSVW-based validation! [\#142](https://github.com/theodi/csvlint.rb/pull/142) ([JeniT](https://github.com/JeniT))

## [0.1.4](https://github.com/theodi/csvlint.rb/tree/0.1.4) (2015-08-06)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.3...0.1.4)

**Merged pull requests:**

- change made to the constraint parameter in order that it is more cons… [\#140](https://github.com/theodi/csvlint.rb/pull/140) ([quadrophobiac](https://github.com/quadrophobiac))

## [0.1.3](https://github.com/theodi/csvlint.rb/tree/0.1.3) (2015-07-24)

[Full Changelog](https://github.com/theodi/csvlint.rb/compare/0.1.2...0.1.3)

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

- Speed up \#build\_formats \(changes its API\) [\#103](https://github.com/theodi/csvlint.rb/pull/103) ([jpmckinney](https://github.com/jpmckinney))

- Continuously deploy gem [\#102](https://github.com/theodi/csvlint.rb/pull/102) ([pezholio](https://github.com/pezholio))

- Make csvlint way faster [\#99](https://github.com/theodi/csvlint.rb/pull/99) ([jpmckinney](https://github.com/jpmckinney))

- Update README.md [\#98](https://github.com/theodi/csvlint.rb/pull/98) ([rmalecky](https://github.com/rmalecky))

- Undeclared header error [\#95](https://github.com/theodi/csvlint.rb/pull/95) ([Floppy](https://github.com/Floppy))

- Blank values shouldn't count as inconsistencies [\#91](https://github.com/theodi/csvlint.rb/pull/91) ([pezholio](https://github.com/pezholio))

- Use `reject` instead of `delete\_if` [\#89](https://github.com/theodi/csvlint.rb/pull/89) ([pezholio](https://github.com/pezholio))

- Raise a warning if a title row is found [\#88](https://github.com/theodi/csvlint.rb/pull/88) ([pezholio](https://github.com/pezholio))

- Improve executable [\#86](https://github.com/theodi/csvlint.rb/pull/86) ([pezholio](https://github.com/pezholio))

- Feature undeclared header [\#83](https://github.com/theodi/csvlint.rb/pull/83) ([ldodds](https://github.com/ldodds))

- Support xsd:integer [\#82](https://github.com/theodi/csvlint.rb/pull/82) ([ldodds](https://github.com/ldodds))

- Downgrade header errors [\#81](https://github.com/theodi/csvlint.rb/pull/81) ([ldodds](https://github.com/ldodds))

- Go home, pry [\#78](https://github.com/theodi/csvlint.rb/pull/78) ([pikesley](https://github.com/pikesley))

- Use type validations to check consistency [\#77](https://github.com/theodi/csvlint.rb/pull/77) ([pezholio](https://github.com/pezholio))

- Add data accessor [\#76](https://github.com/theodi/csvlint.rb/pull/76) ([Floppy](https://github.com/Floppy))

- Add failed constraints to schema errors [\#75](https://github.com/theodi/csvlint.rb/pull/75) ([ldodds](https://github.com/ldodds))

- Only perform ragged row check if there's no schema [\#74](https://github.com/theodi/csvlint.rb/pull/74) ([ldodds](https://github.com/ldodds))

- Handle tempfiles [\#73](https://github.com/theodi/csvlint.rb/pull/73) ([pezholio](https://github.com/pezholio))

- Catch errors if regex doesn't match [\#72](https://github.com/theodi/csvlint.rb/pull/72) ([pezholio](https://github.com/pezholio))

- Inconsistent column base [\#70](https://github.com/theodi/csvlint.rb/pull/70) ([ldodds](https://github.com/ldodds))

- include column name in :header\_name message [\#68](https://github.com/theodi/csvlint.rb/pull/68) ([Floppy](https://github.com/Floppy))

- Record default dialect [\#67](https://github.com/theodi/csvlint.rb/pull/67) ([pezholio](https://github.com/pezholio))

- Schema validation message improvements [\#65](https://github.com/theodi/csvlint.rb/pull/65) ([Floppy](https://github.com/Floppy))

- Fix ignore empty fields [\#62](https://github.com/theodi/csvlint.rb/pull/62) ([ldodds](https://github.com/ldodds))

- Create stub schema from existing CSV file [\#61](https://github.com/theodi/csvlint.rb/pull/61) ([ldodds](https://github.com/ldodds))

- Validate dates [\#59](https://github.com/theodi/csvlint.rb/pull/59) ([ldodds](https://github.com/ldodds))

- add schema access from validator [\#58](https://github.com/theodi/csvlint.rb/pull/58) ([Floppy](https://github.com/Floppy))

- Allow schema and fields to have title and description [\#57](https://github.com/theodi/csvlint.rb/pull/57) ([ldodds](https://github.com/ldodds))

- Feature min max ranges [\#56](https://github.com/theodi/csvlint.rb/pull/56) ([ldodds](https://github.com/ldodds))

- Check header without schema [\#54](https://github.com/theodi/csvlint.rb/pull/54) ([ldodds](https://github.com/ldodds))

- Validate types [\#53](https://github.com/theodi/csvlint.rb/pull/53) ([pikesley](https://github.com/pikesley))

- Added open\_uri\_redirections to allow HTTP/HTTPS transfers [\#52](https://github.com/theodi/csvlint.rb/pull/52) ([ldodds](https://github.com/ldodds))

- Added docs on CSV options and header error/warning messages [\#51](https://github.com/theodi/csvlint.rb/pull/51) ([ldodds](https://github.com/ldodds))

- Feature header validation [\#50](https://github.com/theodi/csvlint.rb/pull/50) ([ldodds](https://github.com/ldodds))

- Handle unique columns [\#49](https://github.com/theodi/csvlint.rb/pull/49) ([pikesley](https://github.com/pikesley))

- Validate all the fields [\#47](https://github.com/theodi/csvlint.rb/pull/47) ([ldodds](https://github.com/ldodds))

- Tolerate incomplete schemas [\#46](https://github.com/theodi/csvlint.rb/pull/46) ([ldodds](https://github.com/ldodds))

- Add accessor for line breaks [\#45](https://github.com/theodi/csvlint.rb/pull/45) ([Floppy](https://github.com/Floppy))

- update README for info messages and new error types [\#44](https://github.com/theodi/csvlint.rb/pull/44) ([Floppy](https://github.com/Floppy))

- Info messages for line breaks [\#43](https://github.com/theodi/csvlint.rb/pull/43) ([Floppy](https://github.com/Floppy))

- Add category to messages [\#40](https://github.com/theodi/csvlint.rb/pull/40) ([ldodds](https://github.com/ldodds))

- Badges [\#39](https://github.com/theodi/csvlint.rb/pull/39) ([pikesley](https://github.com/pikesley))

- Generic field validation using JSON Table Schema [\#38](https://github.com/theodi/csvlint.rb/pull/38) ([ldodds](https://github.com/ldodds))

- Feature validate strings and files [\#37](https://github.com/theodi/csvlint.rb/pull/37) ([ldodds](https://github.com/ldodds))

- Support reporting of column number in errors [\#36](https://github.com/theodi/csvlint.rb/pull/36) ([ldodds](https://github.com/ldodds))

- Fix up casing of keys in CSV DDF options [\#35](https://github.com/theodi/csvlint.rb/pull/35) ([ldodds](https://github.com/ldodds))

- Add errors for incorrect newlines [\#34](https://github.com/theodi/csvlint.rb/pull/34) ([pezholio](https://github.com/pezholio))

- Change from parsing CSV line by line to using CSV.new and trapping errors [\#33](https://github.com/theodi/csvlint.rb/pull/33) ([ldodds](https://github.com/ldodds))

- Improved the README, tweaked LICENSE [\#28](https://github.com/theodi/csvlint.rb/pull/28) ([ldodds](https://github.com/ldodds))

- Handle 404s [\#26](https://github.com/theodi/csvlint.rb/pull/26) ([pezholio](https://github.com/pezholio))

- Create more fine-grained errors and warnings for content type issues [\#25](https://github.com/theodi/csvlint.rb/pull/25) ([ldodds](https://github.com/ldodds))

- Report trailing empty rows as an error. Previously threw exception [\#24](https://github.com/theodi/csvlint.rb/pull/24) ([ldodds](https://github.com/ldodds))

- Simplify the guessing of column types [\#22](https://github.com/theodi/csvlint.rb/pull/22) ([ldodds](https://github.com/ldodds))

- Class-ify error messages [\#21](https://github.com/theodi/csvlint.rb/pull/21) ([pezholio](https://github.com/pezholio))

- Error extracts [\#20](https://github.com/theodi/csvlint.rb/pull/20) ([Floppy](https://github.com/Floppy))

- Return headers [\#19](https://github.com/theodi/csvlint.rb/pull/19) ([pezholio](https://github.com/pezholio))

- Return a warning if no character set specified [\#18](https://github.com/theodi/csvlint.rb/pull/18) ([pezholio](https://github.com/pezholio))

- Ignore query params [\#17](https://github.com/theodi/csvlint.rb/pull/17) ([Floppy](https://github.com/Floppy))

- Add invalid\_encoding error for invalid byte sequences [\#16](https://github.com/theodi/csvlint.rb/pull/16) ([ldodds](https://github.com/ldodds))

- Check inconsistent values [\#13](https://github.com/theodi/csvlint.rb/pull/13) ([pezholio](https://github.com/pezholio))

- Add CSV dialect options [\#11](https://github.com/theodi/csvlint.rb/pull/11) ([pezholio](https://github.com/pezholio))

- Return warning if extension doesn't match content type [\#10](https://github.com/theodi/csvlint.rb/pull/10) ([pezholio](https://github.com/pezholio))

- Return warnings for file extension [\#8](https://github.com/theodi/csvlint.rb/pull/8) ([pezholio](https://github.com/pezholio))

- Detect blank rows [\#7](https://github.com/theodi/csvlint.rb/pull/7) ([pezholio](https://github.com/pezholio))

- Detect bad content type [\#3](https://github.com/theodi/csvlint.rb/pull/3) ([pezholio](https://github.com/pezholio))

- Return information about CSV [\#1](https://github.com/theodi/csvlint.rb/pull/1) ([pezholio](https://github.com/pezholio))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*