class StdoutOutputServer
  class << self
    def usage_output
       <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
              HUCKLEBERRY USAGE
- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN AS EMAIL:

bin/huckleberry <relative_path_to_log>

    Will scan the given logfile, and send
    an email with that relevant info.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN IN TEST EMAIL MODE:

mailcatcher
bin/huckleberry <relative_path_to_log> mailcatcher

  navivate to localhost:1080 to see incoming mail.

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO RUN IN VIM:

bin/huckleberry <relative_path_to_log> vim

- - - - - - - - - - - - - - - - - - - - - - - - - -
TO SEE A LIST OF LOGFILE KEYWORDS:

bin/huckleberry keywords

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

    bin/huckleberry keywords

      OUTPUT
    end

    def keywords_output
      <<-OUTPUT
- - - - - - - - - - - - - - - - - - - - - - - - - -
             HUCKLEBERRY KEYWORDS
- - - - - - - - - - - - - - - - - - - - - - - - - -

#{File.read(File.join(File.dirname(__FILE__) + "/../config/log_keywords.yml"))}

      OUTPUT
    end
  end
end
