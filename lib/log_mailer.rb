require_relative '../helpers/app_helper'


class LogMailer
  attr_reader :message

  def initialize(message, count_output, important_log_output, duplicate_logs, duplicate_log_count)
    @message = message
    @important_log_output = important_log_output
    @count_output = count_output
    @duplicate_log_count = duplicate_log_count
    @duplicate_logs = duplicate_logs
  end

  def send_mail
    mailer_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/email_options.yml"))
    message = @message.strip!
    file = create_file
    Mail.deliver do
      from        mailer_config['from']
      to          mailer_config['standard_recipients']
      subject     mailer_config['standard_subject']
      body        message
      add_file    file.path
    end
  end
  private

  attr_reader :important_log_output, :count_output, :duplicate_logs, :duplicate_log_count

  def create_file
    root = "/Users/amcfadden/repos/huckleberry"
    f = File.new("parsed_logs/#{DateTime.now.to_s}_huckleberry_log", "w")
    f.puts(count_output)
    f.puts(important_log_output)
    if duplicate_log_count > 0
      f.puts(duplicate_log_count.to_s + " duplicates found")
      f.puts(duplicate_logs)
      f.puts("_______________________________________________")
    end
    f.close
    return f
  end
end
