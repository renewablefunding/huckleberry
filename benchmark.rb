require 'benchmark/ips'

Benchmark.ips do |x|
  # Configure the number of seconds used during
  # the warmup phase (default 2) and calculation phase (default 5)
  x.config(:time => 5, :warmup => 2)

  # These parameters can also be configured this way
  x.time = 5
  x.warmup = 2
  @foo = "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
  # Typical mode, runs the block as many times as it can
  x.report("gsub") {
    @http_verb ||= @foo.gsub(/[^A-Z]/, '')
  }


  x.report("gsub!") {
    @http_verb ||= @foo.gsub!(/[^A-Z]/, '')
  }

  # To reduce overhead, the number of iterations is passed in
  # and the block must run the code the specific number of times.
  # Used for when the workload is very small and any overhead
  # introduces incorrectable errors.
  x.report("tr") {
    @http_verb ||= @foo.tr('^A-Z', '')
  }

  # To reduce overhead even more, grafts the code given into
  # the loop that performs the iterations internally to reduce
  # overhead. Typically not needed, use the |times| form instead.
  # x.report("addition3", "1 + 2")

  # Really long labels should be formatted correctly
  # x.report("addition-test-long-label") { 1 + 2 }

  # Compare the iterations per second of the various reports!
  x.compare!
end
