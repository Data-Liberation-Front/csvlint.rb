module Csvlint

  class CsvwDateFormat

    attr_reader :pattern

    def initialize(pattern)
      @pattern = pattern

      @regexp = DATE_PATTERN_REGEXP[@pattern]
      @type = @regexp.nil? ? :time : :date
      @regexp = @regexp || TIME_PATTERN_REGEXP[@pattern]
      @type = @regexp.nil? ? :dateTime : @type
      @regexp = @regexp || DATE_TIME_PATTERN_REGEXP[@pattern]
      if @regexp.nil?
        regexp = @pattern
        @type = :time
        regexp = regexp.sub("HH", FIELDS["HH"].to_s)
        regexp = regexp.sub("mm", FIELDS["mm"].to_s)
        if @pattern =~ /ss\.S+/
          max_fractional_seconds = @pattern.split(".")[-1].length
          regexp = regexp.sub(/ss\.S+$/, "(?<second>#{FIELDS["ss"]}(\.[0-9]{1,#{max_fractional_seconds}})?)")
        else
          regexp = regexp.sub("ss", "(?<second>#{FIELDS["ss"]})")
        end
        if regexp =~ /yyyy/
          @type = :dateTime
          regexp = regexp.sub("yyyy", FIELDS["yyyy"].to_s)
          regexp = regexp.sub("MM", FIELDS["MM"].to_s)
          regexp = regexp.sub("M", FIELDS["M"].to_s)
          regexp = regexp.sub("dd", FIELDS["dd"].to_s)
          regexp = regexp.sub(/d(?=[-T \/\.])/, FIELDS["d"].to_s)
        end
        regexp = regexp.sub("XXX", FIELDS["XXX"].to_s)
        regexp = regexp.sub("XX", FIELDS["XX"].to_s)
        regexp = regexp.sub("X", FIELDS["X"].to_s)
        regexp = regexp.sub("xxx", FIELDS["xxx"].to_s)
        regexp = regexp.sub("xx", FIELDS["xx"].to_s)
        regexp = regexp.sub("x", FIELDS["x"].to_s)
        @regexp = Regexp.new("^#{regexp}$")
      end
    end

    def match(value)
      value =~ @regexp ? true : false
    end

    def parse(value)
      match = @regexp.match(value)
      return nil if match.nil?
      case @type
      when :date
        begin
          return Date.new(match["year"].to_i, match["month"].to_i, match["day"].to_i)
        rescue ArgumentError
          return nil
        end
      when :dateTime
        begin
          return DateTime.new(match["year"].to_i, match["month"].to_i, match["day"].to_i, match["hour"].to_i, match["minute"].to_i, (match.names.include?("second") ? match["second"].to_f : 0), match.names.include?("timezone") ? match["timezone"] : '')
        rescue ArgumentError
          return nil
        end
      else
        time = {
          "hour" => match["hour"].to_i,
          "minute" => match["minute"].to_i
        }
        time["second"] = match["second"].to_f if match.names.include?("second")
        if match.names.include?("timezone")
          tz = match["timezone"]
          tz = "+00:00" if tz == 'Z'
          tz += ':00' if tz.length == 3
          tz = "#{tz[0..2]}:#{tz[3..4]}" unless tz =~ /:/
          time["timezone"] = tz
        end
        return time
      end
    end

    private
      FIELDS = {
        "yyyy" => /(?<year>[0-9]{4})/,
        "MM" => /(?<month>[0-1][0-9])/,
        "M" => /(?<month>1?[0-9])/,
        "dd" => /(?<day>[0-3][0-9])/,
        "d" => /(?<day>[1-3]?[0-9])/,
        "HH" => /(?<hour>[0-1][0-9])/,
        "mm" => /(?<minute>[0-5][0-9])/,
        "ss" => /([0-6][0-9])/,
        "X" => /(?<timezone>Z|[-+][0-1][0-9]([0-5][0-9])?)/,
        "XX" => /(?<timezone>Z|[-+][0-1][0-9][0-5][0-9])/,
        "XXX" => /(?<timezone>Z|[-+][0-1][0-9]:[0-5][0-9])/,
        "x" => /(?<timezone>[-+][0-1][0-9]([0-5][0-9])?)/,
        "xx" => /(?<timezone>[-+][0-1][0-9][0-5][0-9])/,
        "xxx" => /(?<timezone>[-+][0-1][0-9]:[0-5][0-9])/,
      }

      DATE_PATTERN_REGEXP = {
        "yyyy-MM-dd" => Regexp.new("^#{FIELDS["yyyy"]}-#{FIELDS["MM"]}-#{FIELDS["dd"]}$"),
        "yyyyMMdd" => Regexp.new("^#{FIELDS["yyyy"]}#{FIELDS["MM"]}#{FIELDS["dd"]}$"),
        "dd-MM-yyyy" => Regexp.new("^#{FIELDS["dd"]}-#{FIELDS["MM"]}-#{FIELDS["yyyy"]}$"),
        "d-M-yyyy" => Regexp.new("^#{FIELDS["d"]}-#{FIELDS["M"]}-#{FIELDS["yyyy"]}$"),
        "MM-dd-yyyy" => Regexp.new("^#{FIELDS["MM"]}-#{FIELDS["dd"]}-#{FIELDS["yyyy"]}$"),
        "M-d-yyyy" => Regexp.new("^#{FIELDS["M"]}-#{FIELDS["d"]}-#{FIELDS["yyyy"]}$"),
        "dd/MM/yyyy" => Regexp.new("^#{FIELDS["dd"]}/#{FIELDS["MM"]}/#{FIELDS["yyyy"]}$"),
        "d/M/yyyy" => Regexp.new("^#{FIELDS["d"]}/#{FIELDS["M"]}/#{FIELDS["yyyy"]}$"),
        "MM/dd/yyyy" => Regexp.new("^#{FIELDS["MM"]}/#{FIELDS["dd"]}/#{FIELDS["yyyy"]}$"),
        "M/d/yyyy" => Regexp.new("^#{FIELDS["M"]}/#{FIELDS["d"]}/#{FIELDS["yyyy"]}$"),
        "dd.MM.yyyy" => Regexp.new("^#{FIELDS["dd"]}.#{FIELDS["MM"]}.#{FIELDS["yyyy"]}$"),
        "d.M.yyyy" => Regexp.new("^#{FIELDS["d"]}.#{FIELDS["M"]}.#{FIELDS["yyyy"]}$"),
        "MM.dd.yyyy" => Regexp.new("^#{FIELDS["MM"]}.#{FIELDS["dd"]}.#{FIELDS["yyyy"]}$"),
        "M.d.yyyy" => Regexp.new("^#{FIELDS["M"]}.#{FIELDS["d"]}.#{FIELDS["yyyy"]}$")
      }

      TIME_PATTERN_REGEXP = {
        "HH:mm:ss" => Regexp.new("^#{FIELDS["HH"]}:#{FIELDS["mm"]}:(?<second>#{FIELDS["ss"]})$"),
        "HHmmss" => Regexp.new("^#{FIELDS["HH"]}#{FIELDS["mm"]}(?<second>#{FIELDS["ss"]})$"),
        "HH:mm" => Regexp.new("^#{FIELDS["HH"]}:#{FIELDS["mm"]}$"),
        "HHmm" => Regexp.new("^#{FIELDS["HH"]}#{FIELDS["mm"]}$")
      }

      DATE_TIME_PATTERN_REGEXP = {
        "yyyy-MM-ddTHH:mm:ss" => Regexp.new("^#{FIELDS["yyyy"]}-#{FIELDS["MM"]}-#{FIELDS["dd"]}T#{FIELDS["HH"]}:#{FIELDS["mm"]}:(?<second>#{FIELDS["ss"]})$"),
        "yyyy-MM-ddTHH:mm" => Regexp.new("^#{FIELDS["yyyy"]}-#{FIELDS["MM"]}-#{FIELDS["dd"]}T#{FIELDS["HH"]}:#{FIELDS["mm"]}$")
      }

  end

  class CsvwDateFormatError < StandardError

  end

end
