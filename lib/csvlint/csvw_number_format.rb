module Csvlint

  class CsvwNumberFormat

    attr_reader :pattern, :prefix, :numeric_part, :suffix, :grouping_separator, :decimal_separator, :primary_grouping_size, :secondary_grouping_size, :fractional_grouping_size

    def initialize(pattern, grouping_separator=",", decimal_separator=".")
      @pattern = pattern
      @grouping_separator = grouping_separator
      @decimal_separator = decimal_separator

      numeric_part_regexp = Regexp.new("(?<numeric_part>(0|#|#{Regexp.escape(@grouping_separator)}|#{Regexp.escape(@decimal_separator)})+)")
      number_format_regexp = Regexp.new("^(?<prefix>.*?)#{numeric_part_regexp}(?<suffix>.*?)$")
      match = number_format_regexp.match(pattern)
      @prefix = match["prefix"]
      @numeric_part = match["numeric_part"]
      @suffix = match["suffix"]

      parts = @numeric_part.split(@decimal_separator)
      # raise CsvwNumberFormatError, "more than two decimal separators in number format" if parts.length > 2
      integer_part = parts[0]
      fractional_part = parts[1] || ""

      min_integer_digits = integer_part.gsub(@grouping_separator, "").gsub("#", "").length
      min_fraction_digits = fractional_part.gsub(@grouping_separator, "").gsub("#", "").length
      max_fraction_digits = fractional_part.gsub(@grouping_separator, "").length

      integer_parts = integer_part.split(@grouping_separator)[1..-1]
      @primary_grouping_size = integer_parts[-1].length rescue 0
      @secondary_grouping_size = integer_parts[-2].length rescue @primary_grouping_size

      fractional_parts = fractional_part.split(@grouping_separator)[0..-2]
      @fractional_grouping_size = fractional_parts[0].length rescue 0

      if @primary_grouping_size == 0
        integer_regexp = "[0-9]*[0-9]{#{min_integer_digits}}"
      else
        leading_regexp = "([0-9]{0,#{@secondary_grouping_size - 1}}#{Regexp.escape(@grouping_separator)})?"
        secondary_groups = "([0-9]{#{@secondary_grouping_size}}#{Regexp.escape(@grouping_separator)})*"
        final_optional_digits = @primary_grouping_size - min_integer_digits > 0 ? "[0-9]{1,#{@primary_grouping_size - min_integer_digits}}" : ""
        integer_regexp = "(#{leading_regexp}#{secondary_groups}#{final_optional_digits})?[0-9]{#{min_integer_digits}}"
      end

      numeric_part_regexp = integer_regexp

      if max_fraction_digits > 0
        if @fractional_grouping_size == 0
          fractional_regexp = ""
          fractional_regexp += "[0-9]{#{min_fraction_digits}}" if min_fraction_digits > 0
          fractional_regexp += "[0-9]{0,#{max_fraction_digits - min_fraction_digits}}" unless min_fraction_digits == max_fraction_digits
          fractional_regexp = "#{Regexp.escape(@decimal_separator)}#{fractional_regexp}"
          fractional_regexp = "(#{fractional_regexp})?" if min_fraction_digits == 0
          numeric_part_regexp += fractional_regexp
        else
          fractional_regexp = ""
          fractional_regexp += "[0-9]{#{min_fraction_digits}}" if min_fraction_digits > 0
          fractional_regexp += "[0-9]{0,#{@fractional_grouping_size - min_fraction_digits}}" unless min_fraction_digits == @fractional_grouping_size
          fractional_regexp += "(#{Regexp.escape(@grouping_separator)}[0-9]{#{@fractional_grouping_size}}){0,#{max_fraction_digits / @fractional_grouping_size}}" if max_fraction_digits / @fractional_grouping_size > 0
          fractional_regexp += "(#{Regexp.escape(@grouping_separator)}[0-9]{0,#{max_fraction_digits % @fractional_grouping_size}})?" if max_fraction_digits % @fractional_grouping_size > 0
          fractional_regexp = "#{Regexp.escape(@decimal_separator)}#{fractional_regexp}"
          fractional_regexp = "(#{fractional_regexp})?" if min_fraction_digits == 0
          numeric_part_regexp += fractional_regexp
        end
      end
      @regexp = Regexp.new("^" + Regexp.escape(@prefix) + numeric_part_regexp + Regexp.escape(@suffix) + "$")
    end

    def match(value)
      value =~ @regexp ? true : false
    end

  end

  class CsvwNumberFormatError < StandardError

  end

end
