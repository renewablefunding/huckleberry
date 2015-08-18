## Huckleberry

A script written in ruby to allow parsing of logs.

logs > sawmill > sawyer > tom sawyer > huckleberry

#### Running

TO RUN AS EMAIL:

```
./bin/huckleberry <relative_path_to_log>
```

Will scan the given logfile, and send
an email with that relevant info.

---
TO RUN IN TEST EMAIL MODE:

```
mailcatcher
./bin/huckleberry <relative_path_to_log> mailcatcher
```

navivate to localhost:1080 to see incoming mail.

---
TO RUN IN VIM:

```
mailcatcher
./bin/huckleberry <relative_path_to_log> vim
```

---

#### todo

* HIGHEST PRIORITY - determine what information is needed from each logfile.
* seperate log_entry class into many classes (one for each type of log)
  * partially done
* test logfiles from many different apps
  * ~use yml files to allow for setups~
* ~QA problem - two calls going at exact same time and creates a sql error because it is trying to create the same exact entry twice. Should be looking for two identical calls followed by an error.~
* ~~refactor to take out unnecessary files~~
* ~~create an executable~~
* ~log sifter will send the file to the correct log parsing class~
* ~log parsing classes will return to a class that handles output of information to email or console~
* ~yml config file can be used to provide keywords for file naming~
* create this as a gem (maybe)
