module Huckleberry
  class LogMailer
    class << self
      def send_mail(html_file: )
        mailer_config = YAML.load_file(File.join(Huckleberry.root ,"/config/email_options.yml"))
        Mail.deliver do
          from        mailer_config.fetch("from"){ nil }
          to          mailer_config.fetch("recipients"){ nil }
          subject     mailer_config.fetch("subject"){ nil }
          html_part do
            content_type 'text/html; charset=UTF-8'
            body "Huckleberry log report attached"
          end
          add_file html_file.path
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
end
