require_relative '../lib/prod_log_parse'
require_relative '../helpers/spec_helper'

RSpec.describe ProdLogParse do
  describe "#parse_log" do
    let(:test_log) {File.open('spec/fixtures/production_test.log')}
    subject { ProdLogParse.new(test_log) }
    it "returns a headline_output string" do
      expect(subject.headline_output).to be_kind_of(String)
    end
    it "returns a counts_output string" do
      expect(subject.counts_output).to be_kind_of(String)
    end
    it "returns a message_body_output string" do
      expect(subject.message_body_output).to be_kind_of(String)
    end
  end
end
