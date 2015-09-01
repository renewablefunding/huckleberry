require_relative '../lib/huckleberry/log_sifter'
require_relative '../helpers/spec_helper'

RSpec.describe Huckleberry::LogSifter do
  describe "#sort_parse_and_return_raw_message (private method)" do
    subject { Huckleberry::LogSifter.new(logfile: "spec/fixtures/production_test.log") }
    it "sorts this logfile to ProdLogParse class" do
      expect(subject.send(:sort_parse_and_return_raw_message)).to be_kind_of(Array)
    end
  end
end
