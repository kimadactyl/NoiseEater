require_relative "../../audiowebsite"
 
require "capybara"
require "capybara/cucumber"
require 'capybara/rspec'
require "rspec" 
require "launchy"


Capybara.app = NoiseEater
include RSpec::Matchers