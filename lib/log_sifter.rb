require 'english'
require_relative './prod_log_parse'
require_relative './log_mailer'
require_relative './log_duplicate_checker'
require_relative '../helpers/app_helper'

class LogSifter
  def initialize(logfile, stdout = $stdout)
    @logfile = logfile
    @stdout = stdout
  end

  def shell_script
    if parsed_logfile = file_sorter
      duplicate_logs = LogDuplicateChecker.new(logfile).duplicate_check
      duplicate_log_count = duplicate_logs.length
      email = LogMailer.new(parsed_logfile.message, parsed_logfile.output, parsed_logfile.important_logs, duplicate_logs, duplicate_log_count)
      email.send_mail
    end
  end

  private
  attr_reader :logfile, :stdout

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
      log.parse_log
    elsif !(filename_array & new_relic_keywords).empty?
      puts "new relic"
    elsif !(filename_array & mailer_keywords).empty?
      puts "mailer logs"
    elsif !(filename_array & process_runner_keywords).empty?
      puts "process runner"
    elsif !(filename_array & thin_keywords).empty?
      puts "thin"
    else
      send_incorrect_log_email
      return false
    end
    return log
  end

  def filename
    File.basename(logfile)
  end

  def send_incorrect_log_email
    non_matched_filename = filename
    mailer_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/email_options.yml"))
    Mail.deliver do
      from        mailer_config['from']
      to          mailer_config['recipients']
      subject     mailer_config['subject_log_not_found']
      body        "An unknown filetype was given to huckleberry. The file name was (#{non_matched_filename}). Please update the log_keywords.yml if you would like this type of file processed in the future!"
    end
  end
end
