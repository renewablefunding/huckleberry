require 'fileutils'

module Huckleberry
  class HtmlFormatter
    class << self
      def html_formatted_message(raw_message: , duplicate_logs: nil, original_logfile_name: )
        formatted_message =<<-HTML
        <html>
          <body>
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
                text-align: center;
              }
              .header-headline-text{
                color: white;
              }
              .right{
                float: right;
                width: 50%;
              }
              .left{
                float: left;
                width: 50%;
              }
            </style>
            <div class="header">
            <h1 class="header-headline-text">Huckleberry</h1>
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
            <div class="left">
              <h4>This logfile is #{original_logfile_name}</h4>
              <p>#{DateTime.now.strftime("This report was made at: %FT%R")}</p>
            </div>
            <div class="right">
              <h4>KEY: [index in log in original file] - [log entry]</h4>
              <p>EX: 9931 - E, [2015-08-07T14:00:30.029282 #22753] ERROR -- : 400:</p>
            </div>
            <hr>
            <h2>FATAL/ERROR and unknown entries</h2>
            <hr>
            <ul>
            <!-- logs inserted here -->
        HTML
        report_of_404s = ""
        other_400s_report = ""
        report_of_500s = ""
        raw_message.each do |line|
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



      def create_html_file(html_formatted_message)
        FileUtils.mkdir_p 'parsed_logs'
        f = File.new(File.join(Dir.pwd,"/parsed_logs/#{DateTime.now.to_s}_huckleberry_log.html"), "w")
        f.puts(html_formatted_message)
        f.close
        return f
      end
    end
  end
end
