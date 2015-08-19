require_relative '../lib/huckleberry/log_sifter'
require_relative '../lib/huckleberry/log_maker'
require_relative '../helpers/spec_helper'

RSpec.describe Huckleberry::LogMaker do
  include Mail::Matchers

  mailer_config = YAML.load_file(File.join(Huckleberry.root, "/config/email_options.yml"))

  describe "#send_mail" do
    context "log type is parseable" do
      subject { Huckleberry::LogSifter.new(logfile: "spec/fixtures/production_test.log" ) }

      before(:each) do
        Mail::TestMailer.deliveries.clear
        subject.run_script
      end

      it { should have_sent_email }

      it { should have_sent_email.from mailer_config.fetch("from"){ nil } }

      it "will send a message to all recipients" do
        expect(Mail::TestMailer.deliveries.first.to.join(", ")).to eq(mailer_config.fetch("recipients"))
      end

      it { should have_sent_email.with_subject mailer_config.fetch("subject"){ nil } }

      it "will have a file attached" do
        expect(Mail::TestMailer.deliveries.first.attachments).to_not eq(nil)
      end
    end

    context "log type is not parseable" do
      subject { Huckleberry::LogSifter.new(logfile: "spec/fixtures/test.log", stdout: FakeStdout.new) }
      it "will have the subject line for subject_log_not_found" do
        Mail::TestMailer.deliveries.clear
        subject.run_script
        expect(Mail::TestMailer.deliveries.first.subject).to eq(mailer_config.fetch("subject_log_not_found"){ nil })
      end
    end
  end
end
