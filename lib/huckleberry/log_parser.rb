module Huckleberry
  class LogParser
    def initialize(logfile)
      @logfile = logfile
      @message = []
    end

    def simple_parse_log(log_type: )
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "/config/log_keywords.yml"))
      if log_type == keyword_config["production_keywords"]
        production_log_parse
      end
    end

    private
    attr_reader :logfile
    attr_accessor :message

    def production_log_parse
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

        message << index.to_s + "  -  " + line
      end
      message
    end
  end
end
