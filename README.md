# Log Sifter

WIP - a script written in ruby to allow parsing of logs

To run:
```
ruby -r "./log_sifter.rb" -e "LogSifter.new('test')"
```

Replace 'test' with desired logfile

#### todo
* determine what information is needed from each logfile.
* test logfiles from many different apps
* ~~refactor to take out unecessary files~~
* ~~create an executable~~
* create this as a gem
* QA problem - two calls going at exact same time and creates a sql error because it is trying to create the same exact entry twice. Should be looking for two identical calls followed by an error.


* Add class to look for two identical lines in the log file
