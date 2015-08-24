require_relative '../../helpers/app_helper'
module Huckleberry
  class LogMaker
    def initialize(message: nil, headline_output: nil, counts_output: nil, important_log_output: nil, duplicate_logs: nil, duplicate_log_count: nil)
      @message = message
      @important_log_output = important_log_output
      @headline_output = headline_output
      @counts_output = counts_output
      @duplicate_log_count = duplicate_log_count
      @duplicate_logs = duplicate_logs
    end

    def open_in_vim
      file_path = create_parsed_logfile.path
      system("vim #{file_path}")
    end

    def send_mail
      mailer_config = YAML.load_file(File.join(Huckleberry.root ,"/config/email_options.yml"))
      message = @message.strip
      file = create_parsed_logfile
      Mail.deliver do
        from        mailer_config.fetch("from"){ nil }
        to          mailer_config.fetch("recipients"){ nil }
        subject     mailer_config.fetch("subject"){ nil }
        body        message
        add_file    file.path
      end
    end

    private

    attr_reader :important_log_output, :counts_output, :duplicate_logs, :duplicate_log_count, :headline_output,:message

    def create_parsed_logfile
      f = File.new(File.join(Dir.pwd,"/parsed_logs/#{DateTime.now.to_s}_huckleberry_log.log"), "w")
      f.puts(headline_output)
      f.puts(counts_output)
      f.puts(list_of_parsed_logs)
      if duplicate_log_count > 0
        f.puts(duplicate_log_count.to_s + " duplicates found")
        f.puts(duplicate_logs)
      end
      f.close
      return f
    end


    def list_of_parsed_logs
      list_of_parsed_logs = ""
      important_log_output.each do |pid, process|
        pid_output =<<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
- - - - - - - - - - - - - - - - - - - - - - - - - -
              PROCESS  #{pid}
- - - - - - - - - - - - - - - - - - - - - - - - - -
- - - - - - - - - - - - - - - - - - - - - - - - - -

        OUTPUT
        list_of_parsed_logs += pid_output
        process.each do |task|
          task_output =<<-OUTPUT
#{task}
          OUTPUT
          list_of_parsed_logs += task_output
        end
      end
      list_of_parsed_logs
    end
  end
end
