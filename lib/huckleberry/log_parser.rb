module Huckleberry
  class LogParser
    def initialize(logfile)
      @logfile = logfile
      @message = []
    end

    def simple_parse_log(log_type: )
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "config", "log_keywords.yml"))
      case log_type
      when keyword_config["production_keywords"]
        production_log_parse
      when keyword_config["mailer_keywords"]
        mailer_log_parse
      when keyword_config["new_relic_keywords"]
        new_relic_log_parse
      when keyword_config["process_runner_keywords"]
        process_runner_log_parse
      when keyword_config["thin_keywords"]
        thin_log_parse
      end
    end

    private
    attr_reader :logfile
    attr_accessor :message

    def production_log_parse
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /Rendered.*(erb|html|builder|template)/
        next if line =~ /Completed (200|302|204)/
        next if line =~ /Redirected to/
        next if line =~ /Parameters: \{.*\}$/
        next if line =~ /Started (GET|POST|PUT|PATCH|DELETE)/
        next if line =~ /(SELECT).*(AS|FROM)/
        next if line =~ /(SET).*\=/
        next if line =~ /truncate/
        next if line =~ /BEGIN/
        next if line =~ /COMMIT/
        next if line =~ /INSERT INTO/
        next if line =~ /(GET).*(200|302)/
        next if line =~ /(updated_at).*(WHERE)/
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
      f.close
      message
    end

    def mailer_log_parse
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2}/
        next if line =~ /Date: .*\+\d{4}/
        next if line =~ /(From:|To:) .*@/
        next if line =~ /Subject: .*/
        next if line =~ /Mime-Version:/
        next if line =~ /Content-Type:/
        next if line =~ /charset\=/
        next if line =~ /Message-ID: \<.*\>/
        next if line =~ /Content-Transfer-Encoding:/
        next if line =~ /View the application here/
        next if line =~ /.*==_mimepart_.*/
        next if line =~ /\(.*resend_email\)/

        message << index.to_s + "  -  " + line
      end
      f.close
      message
    end

    def new_relic_log_parse
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /Starting the New Relic agent/
        next if line =~ /To prevent agent startup add a NEWRELIC_AGENT_ENABLED=false/
        next if line =~ /Reading configuration from config\/newrelic.yml/
        next if line =~ /Environment: \w*$/
        next if line =~ /Application: \w*$/
        next if line =~ /No known dispatcher detected./
        next if line =~ /(Installing|Finished).*instrumentation$/
        next if line =~ /Reporting to: http/
        next if line =~ /Starting Agent shutdown/
        next if line =~ /Dispatcher: thin/
        next if line =~ /Doing deferred dependency-detection before Rack startup/

        message << index.to_s + "  -  " + line
      end
      f.close
      message
    end

    def process_runner_log_parse
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /Launched process/
        next if line =~ /Completing task.*no params needed/
        next if line =~ /\* complete!/
        next if line =~ //

        message << index.to_s + "  -  " + line
      end
      f.close
      message
    end

    def thin_log_parse
      f = File.open(logfile).each_line.each_with_index do |line, index|
        line.strip!
        next if line == ""
        next if line =~ /Status: 200/
        next if line =~ /Api-(Token|Version):/
        next if line =~ /Content-Type:/i
        next if line =~ /transfer-encoding:/
        next if line =~ /connection:/
        next if line =~ /x-newrelic-app-data:/
        next if line =~ /DEBUG -- (request:|response:)/
        next if line =~ /INFO -- : post http/
        next if line =~ /date:.*\"/

        message << index.to_s + "  -  " + line
      end
      f.close
      message
    end
  end
end
