require 'rspec'
require 'mail'
require 'pry'

RSpec.configure do |c|
  c.before :all do
    Mail.defaults {delivery_method :test}
  end
end
