# Huckleberry

WIP - a script written in ruby to allow parsing of logs

logs > sawmill > sawyer > tom sawyer > huckleberry

To run:
```
./bin/sift_logs <relative_path_to_log>
```

Replace 'test' with desired logfile

#### todo
* determine what information is needed from each logfile.
* test logfiles from many different apps
  * use yml files to allow for setups
* create this as a gem
* QA problem - two calls going at exact same time and creates a sql error because it is trying to create the same exact entry twice. Should be looking for two identical calls followed by an error.
* ~~refactor to take out unnecessary files~~
* ~~create an executable~~

* seperate log_entry class into many classes (one for each type of log)
* log sifter will send the file to the correct log parsing class
* log parsing classes will return to a class that handles output of information to email and console

* yml config file can be used to provide keywords for file naming
