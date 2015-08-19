# require './huckleberry/*.rb'

Dir[File.join(File.expand_path("..",__FILE__), 'huckleberry', '*.rb')].each {|f| require f}

module Huckleberry
  def self.root
    spec = Gem::Specification.find_by_name("huckleberry")
    spec.gem_dir
  end
end
