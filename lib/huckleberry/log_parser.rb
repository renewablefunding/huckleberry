module Huckleberry
  class LogParser
    def initialize(logfile)
      @logfile = logfile
      @message = []
    end

    def simple_parse_log(log_type: )
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        begin
          log_type.fetch(log_type.first.first).fetch('parsing_regexp').each do |regexp|
            raise if line =~ regexp.to_regexp
          end
        rescue
          next
        end
        message << index.to_s + "  -  " + line
      end
      f.close
      message
    end

    private
    attr_reader :logfile
    attr_accessor :message
  end
end
