# LogDuplicateChecker will receive chunks of an entire logfile and check for duplicate logs
# Need to also check the last line of previous log against the first line of the next log

module Huckleberry
  class LogDuplicateChecker
    attr_reader :logfile

    def initialize(logfile)
      @logfile = logfile
    end

    def duplicate_check
      duplicate_line_array = []
      previous_log_entry = nil
      File.open(logfile) do |f|
        f.each_line.each_with_index do |line, index|
          next if line.chomp! == ""
          if previous_log_entry == line
            duplicate_line_array << index.to_s
            duplicate_line_array << line
          end
          previous_log_entry = line
        end
      end
      duplicate_line_array
    end
  end
end
