require 'benchmark/bigo'

Benchmark.bigo do |x|
  # generator should construct a test object of the given size
  # example of an Array generator
  # x.generator {|size| (0...size).to_a.shuffle }
  x.generator {|size| "foo bar" * size }

  # or you can use the built in array generator
  # x.generate :array

  # steps is the total number of data points to collect
  # default is 10
  x.steps = 6

  # step_size is the size between steps
  # default is 100
  x.step_size = 200

  # indicates the starting size of the object to test
  # default is 100
  x.min_size = 1000

  # report takes a label and a block.
  # block is passed in the generated object and the size of that object
  # x.report("#at")           {|array, size| array.at rand(size) }
  # x.report("#index")        {|array, size| array.index rand(size) }
  # x.report("#index-miss")   {|array, size| array.index (size + rand(size)) }

  x.report("#gsub") {|string, size| string.gsub("f", "")}
  x.report("#gsub!") {|string, size| string.gsub!("f", "")}
  x.report("#tr") {|string, size| string.tr("f", "")}

  # generate HTML chart using ChartKick
  x.chart! 'chart_array_simple.html'

  # for each report, create a comparison chart showing the report
  # and scaled series for O(log n), O(n), O(n log n), and O(n squared)
  x.compare!

  # generate an ASCII chart using gnuplot
  # works best with only one or two reports
  # otherwise the lines often overlap each other
  x.termplot!

  # generate JSON output
  x.json! 'chart_array_simple.json'

  # generate CSV output
  x.csv! 'chart_array_simple.csv'
end
