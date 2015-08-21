require_relative '../../helpers/app_helper'
require_relative './prod_log_parse'
require_relative './log_maker'
require_relative './log_duplicate_checker'
require_relative './stdout_output_server'


module Huckleberry
  class LogSifter
    def initialize(logfile:, mode: "email", stdout: $stdout)
      @logfile = logfile
      @mode = mode
      @stdout = stdout
    end

    def run_script
      # file_sorter returns false if file type not valid, else it is truthy
      if parsed_logfile = file_sorter
        duplicate_logs = LogDuplicateChecker.new(logfile).duplicate_check
        duplicate_log_count = duplicate_logs.length
        output_log = LogMaker.new(message: parsed_logfile.message_body_output, headline_output: parsed_logfile.headline_output, counts_output: parsed_logfile.counts_output, important_log_output: parsed_logfile.important_processes, duplicate_logs: duplicate_logs, duplicate_log_count: duplicate_log_count)
        send_logfile_to_output(parsed_logfile: parsed_logfile, duplicate_logs: duplicate_logs, duplicate_log_count: duplicate_log_count, output_log: output_log)
      else
        send_incorrect_log_type_output
      end
    end

    private
    attr_reader :logfile, :mode, :stdout

  # file sorting methods

    def file_sorter
      keyword_config = YAML.load_file(File.join(Huckleberry.root, "/config/log_keywords.yml"))

      prod_logs_keywords = keyword_config['production_keywords']
      new_relic_keywords = keyword_config['new_relic_keywords']
      mailer_keywords = keyword_config['mailer_keywords']
      process_runner_keywords = keyword_config['process_runner_keywords']
      thin_keywords = keyword_config['thin_keywords']

      case
      when filename_keywords_match_yml_keywords?(prod_logs_keywords)
        log = ProdLogParse.new(File.open(logfile))
      when filename_keywords_match_yml_keywords?(new_relic_keywords)
        stdout.puts "new relic"
      when filename_keywords_match_yml_keywords?(mailer_keywords)
        stdout.puts "mailer logs"
      when filename_keywords_match_yml_keywords?(process_runner_keywords)
        stdout.puts "process runner"
      when filename_keywords_match_yml_keywords?(thin_keywords)
        stdout.puts "thin"
      else
        return false
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

    def send_logfile_to_output(parsed_logfile: file_sorter, duplicate_logs:, duplicate_log_count:, output_log:)
      case mode
      when "email"
        output_log.send_mail
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        output_log.send_mail
      when "vim"
        output_log.open_in_vim
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
