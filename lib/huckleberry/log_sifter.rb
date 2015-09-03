module Huckleberry
  class LogSifter
    def initialize(logfile:, mode: "email", stdout: $stdout)
      @logfile = logfile
      @mode = mode
      @stdout = stdout
      @log_types_hash = {}
      @log_type_match = {}
    end

    def carry_log_through_process
      if check_for_correct_filetype_send_incorrect_message
        send_logfile_to_output
      end
    end

    private
    attr_reader :logfile, :mode, :stdout, :log_types_hash, :log_type_match

    def check_for_correct_filetype_send_incorrect_message
      huckleberry_config = YAML.load_file(File.join(Dir.pwd, "config", "huckleberry", "huckleberry_config.yml"))
      @log_types_hash = huckleberry_config.fetch('log_types')

      log_types_hash.each do |key, value|
        if filename_keywords_match_yml_keywords?(value.fetch("keywords"))
          @log_type_match[key] = value
        end
      end

      if @log_type_match.empty?
        send_incorrect_log_type_output
      else
        true
      end
    end

    def sort_parse_and_return_raw_message
      log = LogParser.parse_log(logfile: File.open(logfile), log_type: log_type_match)
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
      new_html_object = HtmlFormatter.new(raw_message: sort_parse_and_return_raw_message, duplicate_logs: duplicate_logs, original_logfile_name: filename)
    end

    def duplicate_logs
      LogDuplicateChecker.new(logfile).duplicate_check
    end

    def send_logfile_to_output
      case mode
      when "email"
        LogMailer.send_mail(html_file: html_formatted_message.create_html_file)
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        LogMailer.send_mail(html_file: html_formatted_message.create_html_file)
      when "launchy"
        html_file = html_formatted_message.create_html_file
        Launchy.open(html_file.path)
        stdout.puts "Hucklebery opened a window with launchy"
      else
        stdout.puts StdoutOutputServer.usage_output
      end
    end

    def send_incorrect_log_type_output
      stdout.puts StdoutOutputServer.no_keywords_detected
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
