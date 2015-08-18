require_relative '../lib/log_sifter'
require_relative '../helpers/spec_helper'

RSpec.describe LogMailer do
  include Mail::Matchers

  mailer_config = YAML.load_file(File.join(File.dirname(__FILE__) + "/../config/email_options.yml"))

  describe "#send_mail" do
    context "log type is parseable" do
      subject { LogSifter.new('spec/fixtures/production_test.log') }

      before(:each) do
        Mail::TestMailer.deliveries.clear
        subject.shell_script
      end

      it { should have_sent_email }

      it { should have_sent_email.from mailer_config['from'] }

      it { should have_sent_email.to mailer_config['recipients'] }

      it { should have_sent_email.with_subject mailer_config['subject'] }

      it "will have a file attached" do
        expect(Mail::TestMailer.deliveries.first.attachments).to_not eq(nil)
      end
    end

    context "log type is not parseable" do
      subject { LogSifter.new('spec/fixtures/test.log') }
      it "will have the subject line for subject_log_not_found" do
        Mail::TestMailer.deliveries.clear
        subject.shell_script
        expect(Mail::TestMailer.deliveries.first.subject).to eq(mailer_config['subject_log_not_found'])
      end
    end
  end
end
