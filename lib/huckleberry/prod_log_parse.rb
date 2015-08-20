# ProdLogParse extracts information about individual entries that are passed to it.

module Huckleberry
  class ProdLogParse
    attr_reader :important_logs
    def initialize(log)
      @log = log
      @important_logs = []
      @important_processes = {}
      @counts = {}
      parse_log
      create_important_processes_hash
      store_all_logs_that_are_important_processes
      binding.pry
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

        #{counts["error"].to_s} ERROR's found

        #{counts["fatal"].to_s} FATAL's found

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
    attr_reader :log, :counts, :important_processes

    def parse_log
      count_404 = 0
      count_500 = 0
      count_error = 0
      count_fatal = 0
      log.each_line.each_with_index do |raw_line, index|
        raw_line.strip!
        line = raw_line.split(" : ")[1]
        next if line.nil?
        # next if line =~ (/ 302 /)
        # next if line =~ (/ 200 /)
        # next if line =~ (/Rendered/)
        # next if line =~ (/Param/)
        important_logs << (index.to_s + raw_line) && count_404 += 1 if line =~ (/ 404 /)
        important_logs << (index.to_s + raw_line) && count_500 += 1 if line =~ (/ 500 /)
        important_logs << (index.to_s + raw_line) && count_error += 1 if line =~ (/ERROR/)
        important_logs << (index.to_s + raw_line) && count_fatal += 1 if line =~ (/FATAL/)
      end
      counts["404"] = count_404
      counts["500"] = count_500
      counts["error"] = count_error
      counts["fatal"] = count_fatal
      log.rewind
    end

    def create_important_processes_hash
      important_logs.each do |log_line|
        pid = log_line.match(/#[\d]*/)
        important_processes[pid.to_s] = [] unless important_processes.has_key?(pid)
      end
    end

    def store_all_logs_that_are_important_processes
      log_array = log.readlines
      last_completed_line = 0
      last_with_404 = 0
      important_processes.each_key do |pid|
        log_array.each_with_index do |line, index|
          next unless line.include?(pid)
          line.strip!

          if line =~ (/Started/)
            foo = false
            count = 1
            started_at = index
            until foo
              look_ahead_line = started_at + count
              if look_ahead_line >= log_array.length || log_array[look_ahead_line].nil?
                foo = true
                next
              end
              if !log_array[look_ahead_line].include?(pid)
                # binding.pry
                count += 1
                next
              elsif log_array[look_ahead_line] =~ (/Completed 404/)
                count += 1
                task = log_array.slice(started_at..look_ahead_line)
                task.select! {|line| line.include?pid}
                important_processes[pid] << task
                puts index
                foo = true
              elsif log_array[look_ahead_line] =~ (/Completed/)
                foo = true
                count += 1
                puts index.to_s + "uno"
              else
                count += 1
              end
            end
          end
        end
      end
    end
  end
end


# hash.has_key?("PID")
# hash[:PID] = []
