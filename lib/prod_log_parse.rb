# ProdLogParse extracts information about individual entries that are passed to it.

class ProdLogParse
  attr_reader :important_logs, :counts
  def initialize(log)
    @log = log
    @important_logs = []
    @counts = {}
  end

  def parse_log
    count_404 = 0
    count_500 = 0
    log.each_line.each_with_index do |raw_line, index|
      raw_line.strip!
      line = raw_line.split(" : ")[1]
      next if line.nil?
      next if line =~ (/ 302 /)
      next if line =~ (/ 200 /)
      next if line =~ (/Rendered/)
      next if line =~ (/Param/)
      important_logs << (index.to_s + raw_line) && count_404 += 1 if line =~ (/ 404 /)
      important_logs << (index.to_s + raw_line) && count_500 += 1 if line =~ (/ 500 /)
    end
    counts["404"] = count_404
    counts["500"] = count_500
  end

  def output
  <<-OUTPUT
Huckleberry Logs #{DateTime.now.to_s}

#{counts["404"].to_s} 404's found
#{counts["500"].to_s} 500's found
_______________________________________________
    OUTPUT
  end

  def message
    message = <<-MESSAGE

    Huckleberry Log Report for #{DateTime.now.to_s}


    MESSAGE
  end

  private
  attr_reader :log

end
