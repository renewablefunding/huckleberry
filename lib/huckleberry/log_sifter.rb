module Huckleberry
  class LogSifter
    def initialize(logfile:, mode: "email", stdout: $stdout)
      @logfile = logfile
      @mode = mode
      @stdout = stdout
    end

    def carry_log_through_process
      if check_for_correct_filetype_send_incorrect_message
        send_logfile_to_output(message: html_formatted_message)
      end
    end

    private
    attr_reader :logfile, :mode, :stdout

    def check_for_correct_filetype_send_incorrect_message
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "/config/log_keywords.yml"))
      keyword_config.each_key do |key|
        if filename_keywords_match_yml_keywords?(keyword_config[key])
          return true
        end
      end
      send_incorrect_log_type_output
      return false
    end

    def sort_parse_and_return_raw_message
      log = false
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "/config/log_keywords.yml"))
      keyword_config.each_key do |key|
        log = LogParser.new(File.open(logfile)).simple_parse_log(log_type: keyword_config[key]) if filename_keywords_match_yml_keywords?(keyword_config[key])
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

    def html_formatted_message
      HtmlFormatter.html_formatted_message(raw_message: sort_parse_and_return_raw_message, duplicate_logs: duplicate_logs, original_logfile_name: filename)
    end

    def duplicate_logs
      LogDuplicateChecker.new(logfile).duplicate_check
    end

    def send_logfile_to_output(message: )
      case mode
      when "email"
        LogMailer.send_mail(message: message, html_tmp_file: HtmlFormatter.create_html_file(message))
        stdout.puts "Hucklebery sent a file to email"
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        LogMailer.send_mail(message: message)
        stdout.puts "Hucklebery sent a file to mailcatcher"
      when "launchy"
        html_file = HtmlFormatter.create_html_file(message)
        Launchy.open(html_file.path)
        stdout.puts "Hucklebery opened a window with launchy"
      else
        stdout.puts StdoutOutputServer.usage_output
      end
    end

    def send_incorrect_log_type_output
      stdout.puts StdoutOutputServer.incorrect_logfile_output
      stdout.puts StdoutOutputServer.usage_output
      case mode
      when "email"
        LogMailer.send_incorrect_log_email
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        LogMailer.send_incorrect_log_email
      end
    end
  end
end
