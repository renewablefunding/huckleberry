require 'erb'
require 'fileutils'

module Huckleberry
  class HtmlFormatter
    def initialize(raw_message: , duplicate_logs: nil, original_logfile_name: )
      @raw_message = raw_message
      @duplicate_logs = duplicate_logs
      @original_logfile_name = original_logfile_name
      @formatted_message = ""
      @erb = nil
    end

    def create_html_file
      read_and_fill_erb
      FileUtils.mkdir_p 'parsed_logs'
      f = File.new(File.join(Dir.pwd,"parsed_logs", "#{DateTime.now.to_s}_huckleberry_log.html"), "w")
      f.write(@erb)
      f.close
      return f
    end

    private

    attr_reader :raw_message, :duplicate_logs, :original_logfile_name
    attr_accessor :formatted_message

    def read_and_fill_erb
      erb = ERB.new(File.read(File.join(Dir.pwd, "helpers", "output_template.erb")))
      @erb = erb.result(binding)
    end
  end
end
