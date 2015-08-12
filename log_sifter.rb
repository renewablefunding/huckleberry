#!/usr/bin/env ruby

# requrie looks in the $LOAD_PATH
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
    if var.length != 1
      show_usage
    end

    logfile = var + ".log"

    non_server_logs_count = 0
    File.open(logfile) do |f|
      f.each_line do |line|
        log_entry = LogParser.new(line).convert_to_array
        log_entry.parse_array
        if log_entry.is_server_log
          puts "Status: " + log_entry.http_code + " - Request: " + log_entry.log_type + " - To: " + log_entry.route + " - From: " + log_entry.client_ip + " - At: " + log_entry.date + " (" + log_entry.timezone + ") "
          puts "________________________________________"
        else
          non_server_logs_count += 1
        end
      end
    end
    puts "Non Server Logs: " + non_server_logs_count.to_s
  end
end

class LogParser
  def initialize(line)
    @line = line
  end

  def convert_to_array
    LogEntry.new(line)
  end

  private

  attr_reader :line

end

class LogEntry
  attr_reader :route, :is_server_log, :log_type, :date, :http_code, :call_time, :timezone, :client_ip

  def initialize(line)
    @line = line
    @array = line.split(" ")
    @route = nil
    @is_server_log = nil
    @log_type = nil
    @date = nil
    @http_code = nil
    @call_time = nil
    @timezone = nil
    @client_ip = nil
  end

  def parse_array
    array.each do |element|
      @date = element.gsub(/\[/, '') if element.include?('[')
      if server_log?
        @route = element if element[0] == '/'
        @log_type = element.gsub(/[^a-zA-Z]/, '') if is_log_element?(element)
        @is_server_log = true
        @timezone = element.gsub(/\]/, '') if element.include?(']')
        @call_time = element if element.match(/\d\.\d{4}/)
        @client_ip = element if (element.match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) && !element.match(/[^\.0-9]/)) && element.count('.') == 3
        @http_code = element unless (element.match(/[\D]/) || element.length != 3)
      else
        @is_server_log = false
      end
    end
  end

  private
  def is_log_element?(string)
    !!(string =~ /(GET|POST|PATCH|DELETE|PUT)/)
  end

  def server_log?
    !!(line =~ /(GET|POST|PATCH|DELETE|PUT) \//)
  end

  attr_reader :line, :array
end
