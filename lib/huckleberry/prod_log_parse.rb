# ProdLogParse extracts information about individual entries that are passed to it.

module Huckleberry
  class ProdLogParse
    attr_reader :important_logs, :counts
    def initialize(log)
      @log = log
      @important_logs = []
      @counts = {}
      parse_log
    end

    def headline_output
      <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -

                  HUCKLEBERRY

            #{DateTime.now.to_s}

- - - - - - - - - - - - - - - - - - - - - - - - - -
        OUTPUT
    end

    def counts_output
    <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -

        #{counts["404"].to_s} 404's found

        #{counts["500"].to_s} 500's found

- - - - - - - - - - - - - - - - - - - - - - - - - -
      OUTPUT
    end

    def message_body_output
      # add in critical finds to the message body
      message = <<-MESSAGE

Huckleberry Log Report for #{DateTime.now.to_s} is attached.

      MESSAGE
    end

    private
    attr_reader :log

    def parse_log
      count_404 = 0
      count_500 = 0
      log.each_line.each_with_index do |raw_line, index|
        raw_line.strip!
        line = raw_line.split(" : ")[1]
        next if line.nil?
        next if line =~ (/ 302 /)
        next if line =~ (/ 200 /)
        next if line =~ (/Rendered/)
        next if line =~ (/Param/)
        important_logs << (index.to_s + raw_line) && count_404 += 1 if line =~ (/ 404 /)
        important_logs << (index.to_s + raw_line) && count_500 += 1 if line =~ (/ 500 /)
      end
      counts["404"] = count_404
      counts["500"] = count_500
    end
  end
end
