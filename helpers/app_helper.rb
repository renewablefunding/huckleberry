require 'pry'
require 'mail'
require 'colorize'
require_relative '../lib/huckleberry'

Mail.defaults {delivery_method :sendmail}
