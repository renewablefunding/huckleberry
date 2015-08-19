require 'rspec'
require 'mail'
require 'pry'

RSpec.configure do |c|
  c.before :all do
    Mail.defaults {delivery_method :test}
    $stdout = FakeStdout.new
  end
end

class FakeStdout
  def initialize
    @output = []
  end

  attr_reader :output

  def puts(msg)
    output << msg
  end

  def write(msg)
    output << msg
  end
end
