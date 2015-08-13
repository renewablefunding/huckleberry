# LogEntry extracts information about individual entries that are passed to it.

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

  def db_call_time
    if !server_log? && array.length > 6
      @db_call_time ||= array[6].tr('^0-9\.','')
    end
  end

  def db_call_time_as_float
    db_call_time.to_f
  end

  private

  attr_reader :line, :array

  def raw_http_verb
    array[5].to_s
  end
end
