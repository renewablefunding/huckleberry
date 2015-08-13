require_relative '../lib/log_duplicate_checker'
require_relative '../helpers/spec_helper'

RSpec.describe LogDuplicateChecker do
  dupe_lines_array = [
    %q(I, [2015-08-10T09:23:43.019875 #72657]  INFO -- : (0.000511s) INSERT INTO "users" ("email", "encrypted_password", "created_at", "identifier") VALUES ('superman@example.com', '$2a$10$3Rg.dbuPccSDJ/C3WkXH0OhlIAIY00/zoHINaSKIxrTzuYhd5Qf3C', '2015-08-10 09:23:43.017301-0700', 'd5ab2eef-4766-4f08-8efa-2a693d4bd522') RETURNING *),
    %q(I, [2015-08-10T09:23:43.163084 #72657]  INFO -- : (0.000267s) SELECT "roles".* FROM "roles" INNER JOIN "memberships" ON ("memberships"."role_id" = "roles"."id") WHERE ("memberships"."user_id" = 1)),
    %q(I, [2015-08-10T09:23:43.347131 #72657]  INFO -- : Started GET "/unauthenticated" for 127.0.0.1 at 2015-08-10 09:23:43 -0700)
  ]

  let(:logfile_path) {'spec/fixtures/test'}
  subject { LogDuplicateChecker.new(logfile_path) }
  it 'will create a LogDuplicateChecker object' do
    expect(subject).to be_a_kind_of LogDuplicateChecker
  end

  describe '#duplicate_check' do
    let(:logfile_path) {'spec/fixtures/dupe_test.log'}
    it 'will return all duplicated lines' do
      expect(subject.duplicate_check).to eq(dupe_lines_array)
    end
  end
end
