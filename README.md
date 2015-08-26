### Huckleberry

Now a gem! A script written in ruby to allow parsing of logs.

logs > sawmill > sawyer > tom sawyer > huckleberry

---

#### Install huckleberry with bundler

Add to Gemfile:

```gem 'huckleberry', :git => 'git@github.com:projectdx/huckleberry.git'```

Requiring within a project:

```require "huckleberry"```

#### Using within project:

Calling the main method to parse logs:
```
Huckleberry::LogSifter.new(logfile: <relative_path_to_logfile>, mode: <default: "email" | "mailcatcher" | "vim">).carry_log_through_process
```

ex:`Huckleberry::LogSifter.new(logfile: logfile_location, mode: "vim").run_script`

---

#### Using as a command line utility

Run `huckleberry` to be informed of the options, or view below:

---
**TO RUN AS EMAIL:**

```
huckleberry <relative_path_to_log>
```

Will scan the given logfile, and send
an email with that relevant info.

**TO RUN IN TEST EMAIL MODE:**

```
mailcatcher
huckleberry <relative_path_to_log> mailcatcher
```

navivate to localhost:1080 to see incoming mail.

---
**TO RUN AND OPEN WITH LAUNCHY:**

```
huckleberry <relative_path_to_log> launchy
```

  A window will pop up with parsed file.


**TO SEE A LIST OF LOGFILE KEYWORDS**

```
huckleberry keywords
```

**TO SEE EMAIL SETTINGS**

```
huckleberry email
```

**TO SET RECIPIENT EMAIL**

```
huckleberry <relative_path_to_log> email <desired_recipient_email>
```

---

#### How to install huckleberry locally for development
```
git clone https://github.com/projectdx/huckleberry.git
cd huckleberry
rake install
```
---

#### Contributing to Huckleberry
* Check out the fix and feature list for current items that need attention.
* submit an issue with fix/feature requests.
* clone repo, make a branch, and pull request your fix/feature

---

#### Fix List

#### Feature List
* Create parsing for logs other than panda production. Using prod_log_parse as template.


#### Done List
* ~~Determine what information is needed from each logfile.~~
* ~~Log parsing currently return duplicates if there is more than one "Started" before a "Completed" is found~~
* ~~make `gem 'huckleberry', :git => 'git@github.com:projectdx/huckleberry.git'` work~~
* ~~allow for `require "huckleberry"` rather than `require_relative`~~
* ~~use yml files to allow for setups~~
* ~~QA problem - two calls going at exact same time and creates a sql error because it is trying to create the same exact entry twice. Should be looking for two identical calls followed by an error.~~
* ~~refactor to take out unnecessary files~~
* ~~create an executable~~
* ~~log sifter will send the file to the correct log parsing class~~
* ~~log parsing classes will return to a class that handles output of information to email or console~~
* ~~yml config file can be used to provide keywords for file naming~~
* ~~create this as a gem (maybe)~~
