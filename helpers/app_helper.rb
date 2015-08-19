require 'pry'
require 'mail'
require_relative '../lib/huckleberry'

Mail.defaults {delivery_method :sendmail}
