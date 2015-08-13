# to run file enter
# ruby -r "./log_sifter.rb" -e "LogSifter.new('<logfile_name>')"
# in the terminal

require 'english'
require_relative 'app_helper'

class LogSifter
  def initialize(logfile, stdout = $stdout)
    @logfile = logfile + ".log"
    @stdout = stdout
    shell_script
  end

  def shell_script
    non_server_logs_count = 0

    status_200_count = 0
    status_302_count = 0
    status_404_count = 0
    status_500_count = 0

    non_tracked_status = 0
    non_tracked_request_verb = 0

    get_request_count = 0
    post_request_count = 0
    patch_request_count = 0
    delete_request_count = 0
    put_request_count = 0

    File.open(logfile) do |f|
      f.each_line do |line|
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        if log_entry.server_log?
          if log_entry.http_code == "200"
            status_200_count += 1
          elsif log_entry.http_code == "302"
            status_302_count += 1
          elsif log_entry.http_code == "404"
            status_404_count += 1
          elsif log_entry.http_code == "500"
            status_500_count += 1
          else
            non_tracked_status += 1
          end

          if log_entry.http_verb == 'GET'
            get_request_count += 1
          elsif log_entry.http_verb == 'POST'
            post_request_count += 1
          elsif log_entry.http_verb == 'PATCH'
            patch_request_count += 1
          elsif log_entry.http_verb == 'DELETE'
            delete_request_count += 1
          elsif log_entry.http_verb == 'PUT'
            put_request_count += 1
          else
            non_tracked_request_verb += 1
          end

request = <<-REQUEST
  Status: #{log_entry.http_code}
    #{log_entry.http_verb} Request to #{log_entry.route}
    From: #{log_entry.client_ip}
    At: #{log_entry.date} #{log_entry.timezone}
- - - - - - - - - - - - - - - - - - - - - - - - -
          REQUEST
          stdout.puts request
        else
          non_server_logs_count += 1
        end
      end
    end
    stdout.puts <<-OUTPUT

    Database Logs: #{non_server_logs_count.to_s}

    HTTP Request Status Logs:
      Status 200: #{status_200_count.to_s}
      Status 302: #{status_302_count.to_s}
      Status 404: #{status_404_count.to_s}
      Status 500: #{status_500_count.to_s}

      Non-tracked Status: #{non_tracked_status.to_s}

    HTTP Request Verb Logs:
      GET: #{get_request_count.to_s}
      POST: #{post_request_count.to_s}
      PATCH: #{patch_request_count.to_s}
      PUT: #{delete_request_count.to_s}
      DELETE: #{put_request_count.to_s}

      Non-tracked verb:
    OUTPUT

    message = <<-MESSAGE

    Non-Server Logs: #{non_server_logs_count.to_s}

    Server Logs:
      Status 200: #{status_200_count.to_s}
      Status 302: #{status_302_count.to_s}
      Status 404: #{status_404_count.to_s}
      Status 500: #{status_500_count.to_s}
    MESSAGE

    mail = Mail.new do
      from    'testemail@test.com'
      to      'amcfadden@renewfund.com'
      subject 'This is a test email'
      body    message
    end

    mail.deliver
  end

  private
  attr_reader :logfile, :stdout

end

class LogEntry
  attr_reader :route, :log_type, :date, :http_code, :call_time, :timezone, :client_ip

  def initialize(line)
    @line = line
    @array = line.split(" ")
  end

  def parse_array
    array.each do |element|
      @date = element.gsub(/\[/, '') if element.include?('[')
      if server_log?
        @route = element if element[0] == '/'
        @timezone = element.gsub(/\]/, '') if element.include?(']')
        @call_time = element if element.match(/\d\.\d{4}/)
        @client_ip = element if (element.match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) && !element.match(/[^\.0-9]/)) && element.count('.') == 3
        @http_code = element unless (element.match(/[\D]/) || element.length != 3)
      end
    end
  end

  def http_verb
    @http_verb ||= raw_http_verb.tr('^A-Z', '')
  end

  def log_type
    server_log? ? "HTTP" : "DATABASE"
  end

  def server_log?
    %w[GET POST PATCH DELETE PUT].any? {|http_verb| raw_http_verb.include? http_verb}
  end
  private

  attr_reader :line, :array

  def raw_http_verb
    array[5].to_s
  end
end
