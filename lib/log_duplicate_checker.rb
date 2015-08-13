# LogDuplicateChecker will receive chunks of an entire logfile and check for duplicate logs
# Need to also check the last line of previous log against the first line of the next log

class LogDuplicateChecker
  attr_reader :logfile

  def initialize(logfile)
    @logfile = logfile
  end

  def duplicate_check
    logfile_array = []
    File.open(@logfile) do |f|
      f.each_line.with_object([]) do |line, logfile_array|
        logfile_array << line.chomp!
      end
    end
    i = 0
    duplicate_line_array = []
    while i < logfile_array.length
      if logfile_array[i] == logfile_array[i + 1]
        duplicate_line_array << logfile_array[i]
      end
      i += 1
    end
    duplicate_line_array
  end
end
