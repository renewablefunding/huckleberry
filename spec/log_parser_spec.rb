require_relative '../lib/huckleberry/log_parser'
require_relative '../helpers/spec_helper'

RSpec.describe Huckleberry::LogParser do
  describe "#simple_parse_log" do
    let(:test_log) {File.open('spec/fixtures/production_test.log')}
    subject { Huckleberry::LogParser.new(test_log) }
  end
end
