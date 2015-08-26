module Huckleberry
  class LogSifter
    def initialize(logfile:, mode: "email", to_email: nil, stdout: $stdout)
      @logfile = logfile
      @mode = mode
      @stdout = stdout
      @to_email = to_email
    end

    def run_script
      # file_sorter returns false if file type not valid, else it is truthy
      if parsed_logfile = file_sorter
        duplicate_logs = LogDuplicateChecker.new(logfile).duplicate_check
        output_log = LogMailer.new(message: parsed_logfile, duplicate_logs: duplicate_logs)
        send_logfile_to_output(parsed_logfile: parsed_logfile, duplicate_logs: duplicate_logs, output_log: output_log)
      else
        send_incorrect_log_type_output
      end
    end

    private
    attr_reader :logfile, :mode, :stdout, :to_email

  # file sorting methods

    def file_sorter
      log = false
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "/config/log_keywords.yml"))
      keyword_config.each_key do |key|
        log = SimpleParse.new(File.open(logfile)).simple_parse_log if filename_keywords_match_yml_keywords?(keyword_config[key])
      end
      return log
    end

    def filename_keywords_match_yml_keywords?(keywords)
      true unless (keywords_from_filename & keywords).empty?
    end

    def keywords_from_filename
      filename.split(".")[0].split(/[\_\-]/)
    end

    def filename
      File.basename(logfile)
    end

  # send logfile output methods

    def send_logfile_to_output(parsed_logfile: file_sorter, duplicate_logs:, output_log:)
      case mode
      when "email"
        output_log.send_mail
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        output_log.send_mail
      else
        stdout.puts StdoutOutputServer.usage_output
      end
    end

  # send incorrect log type output methods

    def send_incorrect_log_type_output
      stdout.puts StdoutOutputServer.incorrect_logfile_output
      stdout.puts StdoutOutputServer.usage_output
      case mode
      when "email"
        send_incorrect_log_email
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        send_incorrect_log_email
      end
    end


    def send_incorrect_log_email
      message_body = StdoutOutputServer.incorrect_logfile_output
      mailer_config = YAML.load_file(File.join(Huckleberry.root, "/config/email_options.yml"))
      Mail.deliver do
        from        mailer_config.fetch("from"){ nil }
        to          mailer_config.fetch("recipients"){ nil }
        subject     mailer_config.fetch("subject_log_not_found"){ nil }
        body        message_body
      end
    end
  end
end
