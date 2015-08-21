## Huckleberry

Now a gem! A script written in ruby to allow parsing of logs.

logs > sawmill > sawyer > tom sawyer > huckleberry

---
### How to install huckleberry locally
```
git clone https://github.com/projectdx/huckleberry.git
cd huckleberry
rake install
```

#### Requiring within a project:
```
require_relative: "<relative/path/to>/huckleberry/lib/huckleberry"
```
ex:
`
require_relative "../../../huckleberry/lib/huckleberry"
`

*This way of requiring is fragile, and is on the list of things to fix so that it can be required simply with the gem name.*


Adding to a Gemfile: ~~`gem 'huckleberry', :git => 'git@github.com:projectdx/huckleberry.git'`~~ *currently not working on my machine, on fix list.*




#### Using within project:

Calling the main method to parse logs:
```
Huckleberry::LogSifter.new(logfile: <relative_path_to_logfile>, mode: <default: "email" | "mailcatcher" | "vim">).run_script
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

---
**TO RUN IN TEST EMAIL MODE:**

```
mailcatcher
huckleberry <relative_path_to_log> mailcatcher
```

navivate to localhost:1080 to see incoming mail.

---
**TO RUN IN VIM:**

```
huckleberry <relative_path_to_log> vim
```

---
**TO SEE A LIST OF LOGFILE KEYWORDS**

```
huckleberry keywords
```

---
**TO SEE EMAIL SETTINGS**

```
huckleberry email
```

---

#### Fix List
* Log parsing currently return duplicates if there is more than one "Started" before a "Completed" is found
* allow for `require "huckleberry"` rather than `require_relative`
* make `gem 'huckleberry', :git => 'git@github.com:projectdx/huckleberry.git'` work

#### Feature List
* HIGHEST PRIORITY - determine what information is needed from each logfile.
* Create parsing for logs other than panda production. Using prod_log_parse as template.


#### Done List
* ~~use yml files to allow for setups~~
* ~~QA problem - two calls going at exact same time and creates a sql error because it is trying to create the same exact entry twice. Should be looking for two identical calls followed by an error.~~
* ~~refactor to take out unnecessary files~~
* ~~create an executable~~
* ~~log sifter will send the file to the correct log parsing class~~
* ~~log parsing classes will return to a class that handles output of information to email or console~~
* ~~yml config file can be used to provide keywords for file naming~~
* ~~create this as a gem (maybe)~~




