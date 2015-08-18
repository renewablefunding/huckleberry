class UsageOutput
  def initialize
    show_usage
  end

  private
  def show_usage
    usage = <<-USAGE
   - - - - - - - - - - - - - - - - - - - - - - - - - -
                WELCOME TO HUCKLEBERRY
   - - - - - - - - - - - - - - - - - - - - - - - - - -
    TO RUN AS EMAIL:

    ./bin/huckleberry <relative_path_to_log>

        Will scan the given logfile, and send
        an email with that relevant info.

   - - - - - - - - - - - - - - - - - - - - - - - - - -
    TO RUN IN TEST EMAIL MODE:

    mailcatcher
    ./bin/huckleberry <relative_path_to_log> mailcatcher

      navivate to localhost:1080 to see incoming mail.

   - - - - - - - - - - - - - - - - - - - - - - - - - -
    TO RUN IN VIM:

    mailcatcher
    ./bin/huckleberry <relative_path_to_log> vim

   - - - - - - - - - - - - - - - - - - - - - - - - - -

    USAGE

    puts usage
  end
end
