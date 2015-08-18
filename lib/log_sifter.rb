require_relative '../helpers/app_helper'
require_relative './prod_log_parse'
require_relative './log_maker'
require_relative './log_duplicate_checker'
require_relative './usage_output'

class LogSifter
  def initialize(logfile, mode = "email")
    @logfile = logfile
  end

  def run_script(mode)
    if parsed_logfile = file_sorter
      duplicate_logs = LogDuplicateChecker.new(logfile).duplicate_check
      duplicate_log_count = duplicate_logs.length
      output_log = LogMaker.new(parsed_logfile.message_body_output, parsed_logfile.headline_output, parsed_logfile.counts_output, parsed_logfile.important_logs, duplicate_logs, duplicate_log_count)
      case mode
      when "email"
        output_log.send_mail
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        output_log.send_mail
      when "vim"
        output_log.open_in_vim
      else
        UsageOutput.show_usage
      end
    else
      case mode
      when "email"
        send_incorrect_log_email
      when "mailcatcher"
        Mail.defaults {delivery_method :smtp, address: "localhost", port: 1025}
        send_incorrect_log_email
      when "vim"
        puts incorrect_logfile_output
      else
        UsageOutput.show_usage
      end
    end
  end

  private
  attr_reader :logfile

  def file_sorter
    keyword_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/log_keywords.yml"))

    prod_logs_keywords = keyword_config['production_keywords']
    new_relic_keywords = keyword_config['new_relic_keywords']
    mailer_keywords = keyword_config['mailer_keywords']
    process_runner_keywords = keyword_config['process_runner_keywords']
    thin_keywords = keyword_config['thin_keywords']

    filename_array = filename.split(".")[0].split(/[\_\-]/)
    if !(filename_array & prod_logs_keywords).empty?
      log = ProdLogParse.new(File.open(logfile))
    elsif !(filename_array & new_relic_keywords).empty?
      puts "new relic"
    elsif !(filename_array & mailer_keywords).empty?
      puts "mailer logs"
    elsif !(filename_array & process_runner_keywords).empty?
      puts "process runner"
    elsif !(filename_array & thin_keywords).empty?
      puts "thin"
    else
      return false
    end
    return log
  end

  def filename
    File.basename(logfile)
  end

  def incorrect_logfile_output
    <<-OUTPUT
      An unknown filetype was given to huckleberry.
      The file name was (#{filename}).

      Please update the log_keywords.yml if you would like this type of file processed in the future!
    OUTPUT
  end

  def send_incorrect_log_email
    message_body = incorrect_logfile_output
    mailer_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/email_options.yml"))
    Mail.deliver do
      from        mailer_config['from']
      to          mailer_config['recipients']
      subject     mailer_config['subject_log_not_found']
      body        message_body
    end
  end
end
