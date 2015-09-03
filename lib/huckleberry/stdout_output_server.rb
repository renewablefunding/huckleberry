module Huckleberry
  class StdoutOutputServer
    class << self
      def usage_output
         <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
              HUCKLEBERRY USAGE
- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN AS EMAIL: use either command

huckleberry <relative_path_to_log>
huckleberry <relative_path_to_log> email

    Will scan the given logfile, and send
    an email with that relevant info.
    This is the default mode.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN IN TEST EMAIL MODE:

mailcatcher
huckleberry <relative_path_to_log> mailcatcher

  navivate to localhost:1080 to see incoming mail.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN AND OPEN WITH LAUNCHY:

huckleberry <relative_path_to_log> launchy

  A window will pop up with parsed file.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO GENERATE CONFIG FILES:

huckleberry g default
huckleberry g blank

These will be located in project_root/config/huckleberry

- - - - - - - - - - - - - - - - - - - - - - - - - -

        OUTPUT
      end

      def no_keywords_detected
        <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
               HUCKLEBERRY ERROR
- - - - - - - - - - - - - - - - - - - - - - - - - -

  No keywords were found in the logfile name.

  Please update the huckleberry_config.yml if you would
  like this type of file processed in the future!

- - - - - - - - - - - - - - - - - - - - - - - - - -

        OUTPUT
      end

      def no_email_set
        <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
               HUCKLEBERRY ERROR
- - - - - - - - - - - - - - - - - - - - - - - - - -

  No recipient emails have been set.

  Please update the huckleberry_config.yml if you would
  like this type of file processed in the future!

- - - - - - - - - - - - - - - - - - - - - - - - - -

        OUTPUT
      end
    end
  end
end
