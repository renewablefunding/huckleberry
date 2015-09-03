module Huckleberry
  class LogParser
    class << self
      def parse_log(logfile: ,log_type: )
        message = []
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
    end
  end
end
