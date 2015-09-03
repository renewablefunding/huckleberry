module Huckleberry
  class LogMailer
    class << self
      def send_mail(html_file: )
        mailer_config = YAML.load_file(File.join(Dir.pwd ,"config", "huckleberry", "huckleberry_config.yml"))
        unless mailer_config.fetch("recipients").include?("@")
          puts "No valid emails in the recipients"
          puts "Edit the huckleberry_config file to fix this"
        else
          Mail.deliver do
            from        mailer_config.fetch("from"){ nil }
            to          mailer_config.fetch("recipients"){ nil }
            subject     mailer_config.fetch("subject"){ nil }
            html_part do
              content_type 'text/html; charset=UTF-8'
              body mailer_config.fetch("message_body"){ nil }
            end
            add_file html_file.path
          end
          puts "Hucklebery sent a file to email"

        end
      end

      def send_incorrect_log_email
        message_body = StdoutOutputServer.incorrect_logfile_output
        mailer_config = YAML.load_file(File.join(Dir.pwd ,"config", "huckleberry", "huckleberry_config.yml"))
        Mail.deliver do
          from        mailer_config.fetch("from"){ nil }
          to          mailer_config.fetch("recipients"){ nil }
          subject     mailer_config.fetch("subject_log_not_found"){ nil }
          body        message_body
        end
        puts "Hucklebery sent a file to mailcatcher"
      end
    end
  end
end
