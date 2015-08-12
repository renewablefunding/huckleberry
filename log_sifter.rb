#!/usr/bin/env ruby

require 'english'
require_relative 'app_helper'

class LogSifter
  def self.show_usage
    puts <<-USAGE

    Usage: ruby -r "./log_sifter.rb" -e "LogSifter.shell_script '<filename>'"

    please provide a logfile name as an argument.

    USAGE
  end

  def self.shell_script(var)
    # currently not being used
    # if var.length != 1
    #   show_usage
    # end

    logfile = var + ".log"

    non_server_logs_count = 0
    status_200_count = 0
    status_302_count = 0
    status_404_count = 0
    status_500_count = 0
    File.open(logfile) do |f|
      f.each_line do |line|
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        if log_entry.server_log?
          status_200_count += 1 if log_entry.http_code == "200"
          status_302_count += 1 if log_entry.http_code == "302"
          status_404_count += 1 if log_entry.http_code == "404"
          status_500_count += 1 if log_entry.http_code == "500"
          puts "Status: " + log_entry.http_code + " - Request: " + log_entry.log_type + " - To: " + log_entry.route + " - From: " + log_entry.client_ip + " - At: " + log_entry.date + " (" + log_entry.timezone + ") "
          puts "________________________________________"

        else
          non_server_logs_count += 1
        end
      end
    end
    puts <<-OUTPUT
    Non-Server Logs: #{non_server_logs_count.to_s}

    Server Logs:
      Status 200: #{status_200_count.to_s}
      Status 302: #{status_302_count.to_s}
      Status 404: #{status_404_count.to_s}
      Status 500: #{status_500_count.to_s}
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
      from    'mcfadden.113@gmail.com'
      to      'amcfadden@renewfund.com'
      subject 'This is a test email'
      body    message
    end

    mail.deliver


  end
end

class LogEntry
  attr_reader :route,  :log_type, :date, :http_code, :call_time, :timezone, :client_ip

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
    # @http_verb ||= array[5].gsub(/[^A-Z]/, '')
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
