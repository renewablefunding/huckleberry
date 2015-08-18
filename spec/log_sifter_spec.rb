require_relative '../lib/log_sifter'
require_relative '../helpers/spec_helper'

RSpec.describe LogSifter do
  describe "#file_sorter (private method)" do
    subject { LogSifter.new('spec/fixtures/production_test.log') }
    it "sorts this logfile to ProdLogParse class" do
      subject.send(:file_sorter)
      expect(subject.send(:file_sorter)).to be_kind_of(ProdLogParse)
    end
  end
end
