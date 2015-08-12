# require_relative looks at the files next to it

require_relative 'log_sifter'
require_relative 'spec_helper'

RSpec.describe LogSifter do
  it 'will return the log entry object' do
    # string literal %q
    line = %q(I, [2015-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
    log_entry = LogParser.new(line).parse
    expect(log_entry).to be_a_kind_of LogEntry
  end

  describe "Date parse testing" do
    it 'will return the date of a log entry' do
      line = %q(I, [2015-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.date).to eq('2015-08-10T11:50:43.088546 #13699')
    end

    it 'will return the date of a log entry' do
      line = %q(I, [2017-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.date).to eq('2017-08-10T11:50:43.088546 #13699')
    end

    it 'will return the date of a log entry' do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.date).to eq('2017-07-10T11:51:43.088546 #13699')
    end
  end

  describe "LogParser will label logs as either server logs or database logs" do
    it "is NOT a server log" do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.server_log?).to be(false)
    end

    it "is NOT a server log" do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "GETasdlkjo3as") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.server_log?).to be(false)
    end

    %w(PATCH POST GET DELETE PUT).each do |http_verb|
      it "is a server log if it contains the http verb #{http_verb}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:43 -0700] "#{http_verb} /authentication/create " 302 - 0.0684)
        log_entry = LogParser.new(line).parse
        expect(log_entry.server_log?).to be(true)
      end
    end
  end

  describe "Log Type parse testing" do
    xit 'will return the log type of a log entry' do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogParser.new(line).parse
      expect(log_entry.type).to eq('INFO')
    end

    pending 'will return the log type of a log entry' do
      line = %q(127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "GET / " 302 - 0.0176)
      log_entry = LogParser.new(line).parse
      expect(log_entry.type).to eq('GET')
    end
  end

  describe "Log route parse testing" do
    it 'will return the log route of a log entry' do
      line = '127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "GET /unauthenticated " 200 - 0.0063'
      log_entry = LogParser.new(line).parse
      expect(log_entry.route).to eq('/unauthenticated')
    end
    it 'will return the log route of a log entry' do
      line = '127.0.0.1 - - [10/Aug/2015:11:50:43 -0700] "POST /authentication/create " 302 - 0.0684'
      log_entry = LogParser.new(line).parse
      expect(log_entry.route).to eq('/authentication/create')
    end
    it 'will return the log route of a log entry' do
      line = '127.0.0.1 - - [10/Aug/2015:11:50:42 -0700] "GET /users " 200 - 0.0102'
      log_entry = LogParser.new(line).convert_to_array
      log_entry.parse_array
      expect(log_entry.route).to eq('/users')
    end
  end
end
