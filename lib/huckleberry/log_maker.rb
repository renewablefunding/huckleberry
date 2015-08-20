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
      f.puts(make_logs_look_pretty)
      if duplicate_log_count > 0
        f.puts(duplicate_log_count.to_s + " duplicates found")
        f.puts(duplicate_logs)
      end
      f.close
      return f
    end


    def make_logs_look_pretty
      output = ""
      important_log_output.each do |pid, process|
        pid_output =<<-BAR
- - - - - - - - - - - - - - - - - - - - - - - - - -
- - - - - - - - - - - - - - - - - - - - - - - - - -
              PROCESS  #{pid}
- - - - - - - - - - - - - - - - - - - - - - - - - -
- - - - - - - - - - - - - - - - - - - - - - - - - -
        BAR
        output += pid_output
        process.each do |task|
          task_output =<<-FOO
#{task.join("\n\n")}

- - - - - - - - - - - - - - - - - - - - - - - - - -

          FOO
          output += task_output
        end
      end
      output
    end
  end
end
