#!/usr/bin/env ruby

# requrie looks in the $LOAD_PATH
require 'english'

class LogSifter
  # heredoc USAGE
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
        puts "/n"
      end
    end
    puts count
  end
end

class LogParser
  def initialize(line)
    @line = line
  end

  def parse
    LogEntry.new(line)
  end

  private

  attr_reader :line

end

class LogEntry
  def initialize(line)
    @line = line
  end

  def date
    date_regexp.match(line).captures.first
  end

  def server_log?
    !!(line =~ /(GET|POST|PATCH|DELETE|PUT) \//)
  end

  private

  attr_reader :line

  def date_regexp
    Regexp.new(/\[(.*)\]/)
  end
end
