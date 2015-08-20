module Huckleberry
  class StdoutOutputServer
    class << self
      def usage_output
         <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
              HUCKLEBERRY USAGE
- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN AS EMAIL:

huckleberry <relative_path_to_log>

    Will scan the given logfile, and send
    an email with that relevant info.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN IN TEST EMAIL MODE:

mailcatcher
huckleberry <relative_path_to_log> mailcatcher

  navivate to localhost:1080 to see incoming mail.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN IN VIM:

huckleberry <relative_path_to_log> vim

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO SEE A LIST OF LOGFILE KEYWORDS:

huckleberry keywords

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO SEE CURRENT EMAIL SETTINGS:

huckleberry email

- - - - - - - - - - - - - - - - - - - - - - - - - -



        OUTPUT
      end

      def incorrect_logfile_output
        <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
               HUCKLEBERRY ERROR
- - - - - - - - - - - - - - - - - - - - - - - - - -

  No keywords were found in the logfile name.

  Please update the log_keywords.yml if you would
  like this type of file processed in the future!

  To see the list of current keywords run:

    huckleberry keywords

        OUTPUT
      end

      def keywords_output
        <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
             HUCKLEBERRY KEYWORDS
- - - - - - - - - - - - - - - - - - - - - - - - - -

#{File.read(File.join(Huckleberry.root, "/config/log_keywords.yml"))}

        OUTPUT
      end

      def email_settings_output
        <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
           HUCKLEBERRY EMAIL SETTINGS
- - - - - - - - - - - - - - - - - - - - - - - - - -

#{File.read(File.join(Huckleberry.root, "/config/email_options.yml"))}

        OUTPUT
      end
    end
  end
end