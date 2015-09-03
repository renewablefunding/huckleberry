### Huckleberry

A ruby script that parses logfiles using regex. Huckleberry parses logs by having the user define what lines should be excluded and reporting back when non-ignored lines are found.

logs > sawmill > sawyer > tom sawyer > huckleberry

---

#### Install huckleberry with bundler

Add to Gemfile:

```
gem 'huckleberry', :git => 'git@github.com:renewablefunding/huckleberry.git'
```

Requiring within a project:

```
require "huckleberry"
```

#### Using as a command line utility

Run `huckleberry` to be informed of the options, or view below:

---
**TO RUN AS EMAIL:** use either command

```
huckleberry <relative_path_to_log>
huckleberry <relative_path_to_log> email
```

Will scan the given logfile, and send
an email with that relevant info.
This is the default mode.

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

---
**TO GENERATE CONFIG FILES:**

```
huckleberry g default
huckleberry g blank
```

These will be located in project_root/config/huckleberry

---

#### Using within project:

Calling the main method to parse logs:
```
Huckleberry::LogSifter.new(logfile: <relative_path_to_logfile>, mode: <default: "email" | "mailcatcher" | "launchy">).carry_log_through_process
```

Example:

```
logfile_location = 'foo/bar/production.log-20159230'
Huckleberry::LogSifter.new(logfile: logfile_location, mode: "launchy").carry_log_through_process
```

---

#### How to install huckleberry locally for development
```
git clone https://github.com/renewablefunding/huckleberry.git
cd huckleberry
rake install
```
---

#### Contributors
* Adam McFadden

#### Contributing to Huckleberry
* Check out the issues and feature list(below) for current items that need attention.
* Fork this repo. implement the fix/feature and then submit a pull request.
  * *Add yourself to the contributors on the README!*
* submit an issue for bugs and/or feature requests.

---

#### Feature List
* refine regex
* attach multiple files to email. Run huckleberry on multiple logs and send only one email.
* be able to set urgency for what is sent in email.
* add thor in for generators. allowing the use to set email and other options during generation.
* find a way to get stack traces. Pull out stack traces associated with erros.
* authenticate from email to keep it from hitting spam.
