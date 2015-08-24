module Huckleberry
  class SimpleParse
    def initialize(logfile)
      @logfile = logfile
      @message = []
    end

    def simple_parse_log
      number_of_interesting_lines = 0
      File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /Rendered.*(erb|html|builder|template)/
        next if line =~ /Completed (200|302|204)/
        next if line =~ /Redirected to/
        next if line =~ /Parameters: \{.*\}$/
        next if line =~ /Started (GET|POST|PUT|PATCH|DELETE)/
        next if line =~ /(SELECT)+.*(AS|FROM)+/
        next if line =~ /(SET)+.*\=+/
        next if line =~ /truncate/
        next if line =~ /BEGIN/
        next if line =~ /COMMIT/
        next if line =~ /INSERT INTO/
        next if line =~ /(GET)+.*(200|302)+/
        next if line =~ /(updated_at)+.*(WHERE)+/
        next if line =~ /Processing by.*Controller/
        next if line =~ /Filter chain halted as/
        next if line =~ /Sent data.*(pdf|docx|english|jpg|jpeg|xlsx|xls|csv|png)/i
        next if line =~ /(POST|PUT|GET|DELETE): http/
        next if line =~ /\{(:headers){1}.*(application\/json).*\}/
        next if line =~ /Requested param.*\]/
        next if line =~ /LDAP.*\[.*\]/
        next if line =~ /LDAP.*connect/
        next if line =~ /sequel_reconnector/
        next if line =~ /AWS (S3|STS) (200|204)/
        next if line =~ /\[AIRBRAKE\] Success/i

        number_of_interesting_lines += 1
        message << index.to_s + "  -  " + line
      end
      message << number_of_interesting_lines.to_s
    end

    private
    attr_reader :logfile
    attr_accessor :message
  end
end
