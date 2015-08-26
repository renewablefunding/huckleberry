require 'fileutils'

module Huckleberry
  class HtmlFormatter
    def initialize(raw_message: , duplicate_logs: nil, original_logfile_name: )
      @raw_message = raw_message
      @duplicate_logs = duplicate_logs
      @original_logfile_name = original_logfile_name
      @formatted_message = ""
    end

    def html_formatted_message
      generate_and_add_opening_html
      generate_css_and_add_to_html
      generate_js_and_add_to_html
      generate_and_add_header_html
      if_no_abnormal_logs_add_notification_to_html
      add_all_log_entries_to_html
      check_for_duplicate_logs_and_add_to_hmtl_if_present
      generate_and_add_closing_html
    end

    def self.create_html_file(message_as_html)
      FileUtils.mkdir_p 'parsed_logs'
      f = File.new(File.join(Dir.pwd,"/parsed_logs/#{DateTime.now.to_s}_huckleberry_log.html"), "w")
      f.puts(message_as_html)
      f.close
      return f
    end

    private

    attr_reader :raw_message, :duplicate_logs, :original_logfile_name
    attr_accessor :formatted_message

    def generate_and_add_opening_html
      formatted_message << <<-HTML
      <html>
        <body>
      HTML
    end

    def generate_css_and_add_to_html
      formatted_message << <<-HTML
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
          background-color: indigo;
          width: 100%;
          text-align: center;
        }
        .header-headline-text{
          color: white;
        }
        .right{
          float: right;
          text-align: center;
          width: 50%;
        }
        .left{
          float: left;
          text-align: center;
          width: 50%;
        }
        .entries-of-404{
          color: brown;
        }
        .entries-of-400s{
          color: DarkOrange;
        }
        .entries-of-500s{
          color: blue;
        }
        .entries-of-fatal{
          color: red;
        }
        .entries-of-error{
          color: indigo;
        }
      </style>
      HTML
    end

    def generate_js_and_add_to_html
      formatted_message << <<-HTML
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
      <script>
      $(function() {
        $("#button-404").click(function() {
          $(".entries-of-404").toggle();
        });
        $("#button-400s").click(function() {
          $(".entries-of-400s").toggle();
        });
        $("#button-500s").click(function() {
          $(".entries-of-500s").toggle();
        });
        $("#button-non-tracked").click(function() {
          $(".entries-non-tracked").toggle();
        });
        $("#button-fatal").click(function() {
          $(".entries-of-fatal").toggle();
        });
        $("#button-error").click(function() {
          $(".entries-of-error").toggle();
        });
      });
      </script>
      HTML
    end

    def generate_and_add_header_html
      formatted_message << <<-HTML
      <div class="header">
      <h1 class="header-headline-text">Huckleberry</h1>
        <button><a style='color: green'>Return to Top</a></button>
        <button id="button-404" style='color: brown'>Show/Hide 404 Status Code</button>
        <button id="button-400s" style='color: DarkOrange'>Show/Hide 400-417(excluding 404) Status Code</button>
        <button id="button-500s" style='color: blue'>Show/Hide 500-505 Status Code</button>
        <button id="button-fatal" style='color: red'>Show/Hide FATAL</button>
        <button id="button-error" style='color: indigo'>Show/Hide ERROR</button>
        <button id="button-non-tracked">Show/Hide Untracked logs</button>
        #{"<button><a href='#duplicate_logs'>Duplicate Logs</a></button>" unless duplicate_logs.empty?}
      </div>
      <div style='margin-top: 100px'>
      <a name="return_to_top" class='anchor'></a>
      <div class="left">
        <h4>This logfile is #{original_logfile_name}</h4>
        <p>This report was made at: #{DateTime.now.to_s}</p>
      </div>
      <div class="right">
        <h4>KEY: [index in log in original file] - [log entry]</h4>
        <p>EX: 9931 - E, [2015-08-07T14:00:30.029282 #22753] ERROR -- : 400:</p>
      </div>
      <hr>
      <ul>
      <!-- logs inserted here -->
      HTML
    end

    def if_no_abnormal_logs_add_notification_to_html
      if raw_message.empty?
        formatted_message << "<h2 style='text-align:center; width:100%; color:indigo;'>No abnormal logs have been found!</h2>"
      end
    end

    def add_all_log_entries_to_html
      raw_message.each do |line|
        if line =~ / 404 /
          formatted_message << "<li class='entries-of-404'>#{line}</li>"
        elsif line =~ / (4(0|1)[0-7]) /
          formatted_message << "<li class='entries-of-400s'>#{line}</li>"
        elsif line =~ /( (50[0-5]) |\(50[0-5]\))/
          formatted_message << "<li class='entries-of-500s'>#{line}</li>"
        elsif line =~ /FATAL/
          formatted_message << "<li class='entries-of-fatal'>#{line}</li>"
        elsif line =~ /ERROR/
          formatted_message << "<li class='entries-of-error'>#{line}</li>"
        else
          formatted_message << "<li class='entries-non-tracked'>#{line}</li>"
        end
      end
    end

    def check_for_duplicate_logs_and_add_to_hmtl_if_present
      if ! duplicate_logs.empty?
        formatted_message << "</ul><h2>Duplicate Logs</h2><hr><ul>"
        formatted_message << duplicate_logs.join("\n\n")
      end
    end

    def generate_and_add_closing_html
      formatted_message << "</ul></div></body></html>"
    end
  end
end
