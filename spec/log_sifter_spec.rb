require_relative '../lib/huckleberry/log_sifter'
require_relative '../helpers/spec_helper'

RSpec.describe Huckleberry::LogSifter do
  describe "#file_sorter (private method)" do
    subject { Huckleberry::LogSifter.new(logfile: "spec/fixtures/production_test.log") }
    it "sorts this logfile to ProdLogParse class" do
      subject.send(:file_sorter)
      expect(subject.send(:file_sorter)).to be_kind_of(Array)
    end
  end
end
