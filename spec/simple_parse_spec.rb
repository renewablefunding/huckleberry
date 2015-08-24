require_relative '../lib/huckleberry/simple_parse'
require_relative '../helpers/spec_helper'

RSpec.describe Huckleberry::SimpleParse do
  describe "#simple_parse_log" do
    let(:test_log) {File.open('spec/fixtures/production_test.log')}
    subject { Huckleberry::SimpleParse.new(test_log) }
  end
end
