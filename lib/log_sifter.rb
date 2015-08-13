# to run file enter:
# ruby -r "./log_sifter.rb" -e "LogSifter.new('<logfile_relative_path>')"
# in the terminal
# or use the bin executable:
# ./bin/sift_logs <relative_path_to_log>

require 'english'
require_relative './log_entry'
require_relative './log_duplicate_checker'
require_relative '../helpers/app_helper'

class LogSifter
  def initialize(logfile, stdout = $stdout)
    @logfile = logfile
    @stdout = stdout
    shell_script
  end

  def shell_script
    #set slow_do_call_metric in seconds
    slow_db_call_metric = 0.010000
    very_slow_db_call_metric = 0.100000

    non_http_logs_count = 0
    http_logs_count = 0

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

    very_slow_db_call_count = 0
    slow_db_call_count = 0

    File.open(logfile) do |f|
      f.each_line do |line|
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        if log_entry.server_log?
          http_logs_count += 1
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
        else
          if log_entry.db_call_time_as_float > slow_db_call_metric
            slow_db_call_count += 1
          elsif log_entry.db_call_time_as_float > very_slow_db_call_metric
            very_slow_db_call_count += 1
          end
          non_http_logs_count += 1
        end
      end
    end

    duplicate_logs = LogDuplicateChecker.new(logfile).duplicate_check
    duplicate_log_count = duplicate_logs.length

# if commented in this will print all HTTP requests to stdout (can be set in app_helper)

# request = <<-REQUEST
#   Status: #{log_entry.http_code}
#     #{log_entry.http_verb} Request to #{log_entry.route}
#     From: #{log_entry.client_ip}
#     At: #{log_entry.date} #{log_entry.timezone}
# - - - - - - - - - - - - - - - - - - - - - - - - -
# REQUEST
# stdout.puts request

# Output to stdout (can be set in app_helper)

    message = <<-OUTPUT

    Number of HTTP Request Logs: #{http_logs_count.to_s}

    HTTP Request Status Logs:
      Status 200: #{status_200_count.to_s}
      Status 302: #{status_302_count.to_s}
      Status 404: #{status_404_count.to_s}
      Status 500: #{status_500_count.to_s}

      Number of non-tracked Status: #{non_tracked_status.to_s}

    HTTP Request Verb Logs:
      GET: #{get_request_count.to_s}
      POST: #{post_request_count.to_s}
      PATCH: #{patch_request_count.to_s}
      PUT: #{delete_request_count.to_s}
      DELETE: #{put_request_count.to_s}

      Number of non-tracked verbs: #{non_tracked_request_verb.to_s}

    Number of Database Logs: #{non_http_logs_count.to_s}

    DB Calls:
      Number of DB calls taking longer than #{slow_db_call_metric.to_s} seconds: #{slow_db_call_count.to_s}
      Number of DB calls taking longer than #{very_slow_db_call_metric.to_s} seconds: #{very_slow_db_call_count.to_s}

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    #{duplicate_log_count} duplicate logs found.

    OUTPUT

    stdout.puts message

    if duplicate_log_count > 0
      duplicate_logs.each do |log|
        dupe_logs_message=<<-DUPE
>     #{log}

        DUPE
        stdout.puts dupe_logs_message
      end
    end

# Email message

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
