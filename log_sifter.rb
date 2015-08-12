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

    count = 0
    File.open(logfile) do |f|
      f.each_line do |line|
        count += 1
        puts line
        puts "_________________________"
      end
    end
    puts count
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
  attr_reader :route, :is_server_log, :log_type, :date

  def initialize(line)
    @line = line
    @array = line.split(" ")
    @route = nil
    @is_server_log = nil
    @log_type = nil
    @date = nil
  end

  def parse_array
    array.each do |element|
      @route = element if element[0] == '/'
      if server_log?
        @log_type = element.gsub(/[^a-zA-Z]/, '') if is_log_element?(element)
        @is_server_log = true
      else
        @is_server_log = false
      end
      @date = element.gsub(/\[/, '') if element.include?('[')
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
