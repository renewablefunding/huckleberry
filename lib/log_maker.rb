require_relative '../helpers/app_helper'

class LogMaker
  def initialize(message, headline_output, counts_output, important_log_output, duplicate_logs, duplicate_log_count)
    @message = message
    @important_log_output = important_log_output
    @headline_output = headline_output
    @counts_output = counts_output
    @duplicate_log_count = duplicate_log_count
    @duplicate_logs = duplicate_logs
  end

  def open_in_vim
    file_path = create_file.path
    system("vim #{file_path}")
  end

  def send_mail
    mailer_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/email_options.yml"))
    message = @message.strip!
    file = create_file
    Mail.deliver do
      from        mailer_config['from']
      to          mailer_config['recipients']
      subject     mailer_config['subject']
      body        message
      add_file    file.path
    end
  end
  
  private

  attr_reader :important_log_output, :counts_output, :duplicate_logs, :duplicate_log_count, :headline_output,:message

  def create_file
    f = File.new("parsed_logs/#{DateTime.now.to_s}_huckleberry_log", "w")
    f.puts(headline_output)
    f.puts(counts_output)
    f.puts(important_log_output)
    if duplicate_log_count > 0
      f.puts(duplicate_log_count.to_s + " duplicates found")
      f.puts(duplicate_logs)
    end
    f.close
    return f
  end
end
