module Huckleberry
  class LogMailer
    def initialize(message: , duplicate_logs: nil)
      @message = message
      @duplicate_logs = duplicate_logs
    end

    def send_mail
      mailer_config = YAML.load_file(File.join(Huckleberry.root ,"/config/email_options.yml"))
      mail_message = html_formatted_message
      Mail.deliver do
        from        mailer_config.fetch("from"){ nil }
        to          mailer_config.fetch("recipients"){ nil }
        subject     mailer_config.fetch("subject"){ nil }
        html_part do
          content_type 'text/html; charset=UTF-8'
          body mail_message
        end
      end
    end

    private
    attr_reader :duplicate_logs
    attr_accessor :message

    def html_formatted_message
      formatted_message =<<-HTML
      <html>
        <body style=''>
          <style>
            .anchor{
            display: block;
            height: 100;
            margin-top: -100;
            visibility: hidden;
            }
            .header{
              position: fixed;
              top: 0;
              background-color: purple;
              width: 100%;
            }
            .header-headline-text{
              color: white;
            }
          </style>
          <div class="header">
          <h2 class="header-headline-text">Huckleberry</h2>
            <button><a href='#return_to_top' style='color: green'>Return to Top</a></button>
            <button><a href='#report_of_404s' id="404-button" style='color: brown'>404 Status Code</a></button>
            <button><a href='#other_400s_report' style='color: orange'>400-417(excluding 404) Status Code</a></button>
            <button><a href='#report_of_500s' style='color: blue'>500-505 Status Code</a></button>
            #{"<button><a href='#duplicate_logs'>Duplicate Logs</a></button>" unless duplicate_logs.empty?}
            <span style="color:red; background-color: white;">FATAL</span>
            <span style="color:purple; background-color: white;">ERROR</span>
          </div>
          <div style='margin-top: 100px'>
          <a name="return_to_top" class='anchor'></a>
          <h2>Fatal and unknown entries</h2>
          <hr>
          <ul>
          <!-- logs inserted here -->
      HTML
      report_of_404s = ""
      other_400s_report = ""
      report_of_500s = ""
      message.each do |line|
        if line =~ / 404 /
          report_of_404s << "<li class='404-entries' style='color: brown'>#{line}</li>"
        elsif line =~ / (4(0|1)[0-7]) /
          other_400s_report << "<li style='color: orange'>#{line}</li>"
        elsif line =~ / (50[0-5]) /
          report_of_500s << "<li style='color: blue'>#{line}</li>"
        elsif line =~ /FATAL/
          formatted_message << "<li style='color: red'>#{line}</li>"
        elsif line =~ /ERROR/
          formatted_message << "<li style='color: purple'>#{line}</li>"
        else
          formatted_message << "<li>#{line}</li>"
        end
      end
      unless duplicate_logs.empty?
        formatted_message << "</ul><a name='duplicate_logs' class='anchor'></a><h2>Duplicate Logs</h2><hr><ul>"
        formatted_message << duplicate_logs.join("\n\n")
      end
      formatted_message << "</ul><a name='report_of_404s' class='anchor'></a><h2>404 Report</h2><hr><ul>"
      formatted_message << report_of_404s
      formatted_message << "</ul><a name='other_400s_report' class='anchor'></a><h2>Other 400s Report</h2><hr><ul>"
      formatted_message << other_400s_report
      formatted_message << "</ul><a name='report_of_500s' class='anchor'></a><h2>500s Report</h2><hr><ul>"
      formatted_message << report_of_500s
      formatted_message << "</ul></div></body></html>"
    end
  end
end
