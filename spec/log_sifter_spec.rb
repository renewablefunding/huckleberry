require_relative '../lib/log_sifter'
require_relative '../helpers/spec_helper'

RSpec.describe LogSifter do

  #EMAIL testing
  class FakeStdout
    def initialize
      @output = []
    end

    attr_reader :output

    def puts(msg)
      output << msg
    end
  end

  describe "sending an email" do
    let(:stdout) {FakeStdout.new}
    subject { LogSifter.new('spec/fixtures/test', stdout) }
    it "receive an email" do
      subject.shell_script
      expect(Mail::TestMailer.deliveries.length > 0).to be(true)
      expect(Mail::TestMailer.deliveries.first.to.first).to eq("amcfadden@renewfund.com")
    end
  end
end
