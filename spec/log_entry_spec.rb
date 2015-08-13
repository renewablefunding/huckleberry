require_relative '../lib/log_entry'
require_relative '../helpers/spec_helper'

RSpec.describe LogEntry do
  it 'will return the log entry object' do
    line = %q(I, [2015-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
    log_entry = LogEntry.new(line)
    log_entry.parse_array
    expect(log_entry).to be_a_kind_of LogEntry
  end

  describe "Date parse testing" do
    it 'will return the date of a log entry' do
      line = %q(I, [2015-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.date).to eq('2015-08-10T11:50:43.088546')
    end

    it 'will return the date of a log entry' do
      line = %q(I, [2017-08-10T11:50:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.date).to eq('2017-08-10T11:50:43.088546')
    end

    it 'will return the date of a log entry' do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.date).to eq('2017-07-10T11:51:43.088546')
    end
    it 'will return the date of a server log entry' do
      line = '127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "GET /unauthenticated " 200 - 0.0063'
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.date).to eq('10/Aug/2015:14:20:43')
    end
  end
  describe 'Timezone field can be parsed' do
    it 'will return timezone field of a server log entry' do
      line = '127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "GET /unauthenticated " 200 - 0.0063'
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.timezone).to eq('-0700')
    end
  end

  describe "LogParser will label logs as either server logs or database logs" do
    it "is NOT a server log" do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "6af5e056a9ed607dd0b") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.server_log?).to be(false)
    end

    it "is NOT a server log" do
      line = %q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "GETasdlkjo3as") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.server_log?).to be(false)
    end

    %w(PATCH POST GET DELETE PUT).each do |http_verb|
      it "is a server log if it contains the http verb #{http_verb}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:43 -0700] "#{http_verb} /authentication/create " 302 - 0.0684)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.server_log?).to be(true)
      end
    end
  end

  describe "Returning the log type of server logs" do
    %w(PATCH POST GET DELETE PUT).each do |http_verb|
      it "will return the log type of a server log entry if it is #{http_verb}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "#{http_verb} / " 302 - 0.0176)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.http_verb).to eq(http_verb)
      end
    end
  end

  describe "Log route parse testing" do
    %w(/unauthenticated /authentication/create /users).each do |route|
      it "will return the log route #{route}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:14:20:43 -0700] "GET #{route} " 200 - 0.0063)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.route).to eq(route)
      end
    end
  end

  describe "Return the correct HTTP status code" do
    %w(200 400 404 500 302).each do |http_code|
      it "will return the HTTP status code #{http_code}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:42 -0700] "GET /users " #{http_code} - 0.0102)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.http_code).to eq(http_code)
      end
    end
    %w(20 40L g404 5000 302f).each do |http_code|
      it "will NOT return the incorrect HTTP status code #{http_code}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:42 -0700] "GET /users " #{http_code} - 0.0102)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.http_code).to eq(nil)
      end
    end
  end

  describe "Return the correct time that the call took" do
    %w(0.0102 1.2133 0.2321 123.1231).each do |call_time|
      it "will return the call time #{call_time}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:42 -0700] "GET /users " 200 - #{call_time})
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.call_time).to eq(call_time)
      end
    end
    %w(102s 12133 0 123.0).each do |call_time|
      it "will NOT return the incorrect call time #{call_time}" do
        line = %Q(127.0.0.1 - - [10/Aug/2015:11:50:42 -0700] "GET /users " 200 - #{call_time})
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.call_time).to eq(nil)
      end
    end
  end

  describe "Return the corrext client IP address" do
    %w(127.0.0.1 1.160.10.240 255.255.24.234 1.1.1.1 3.2.255.13).each do |client_ip|
      it "will return the client_ip #{client_ip}" do
        line = %Q(#{client_ip} - - [10/Aug/2015:11:50:42 -0700] "GET /users " 200 - 0.0102)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.client_ip).to eq(client_ip)
      end
    end
    %w(127.0.0.1.2 1160.10.240 24.234 1.1.1.1a 3225513).each do |client_ip|
      it "will NOT return the incorrect client_ip #{client_ip}" do
        line = %Q(#{client_ip} - - [10/Aug/2015:11:50:42 -0700] "GET /users " 200 - 0.0102)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.client_ip).to eq(nil)
      end
    end
  end

  #DATABASE logs

  describe 'Return the correct time taken for the DB call' do
    %w(0.000192 102.0319203 0.000001 0.302011 023.123123).each do |db_call_time|
      it "will return the DB call time of #{db_call_time}" do
        line = %Q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (#{db_call_time}s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "GETasdlkjo3as") LIMIT 1)
        log_entry = LogEntry.new(line)
        log_entry.parse_array
        expect(log_entry.db_call_time).to eq(db_call_time)
      end
    end
  end

  describe '#db_call_time_as_float' do
    it 'will return the db_call_time as a float' do
      line = %Q(I, [2017-07-10T11:51:43.088546 #13699]  INFO -- : (0.000192s) SELECT 1 AS "one" FROM "sessions" WHERE (sid = "GETasdlkjo3as") LIMIT 1)
      log_entry = LogEntry.new(line)
      log_entry.parse_array
      expect(log_entry.db_call_time_as_float).to eq(0.000192)
    end
  end
end
