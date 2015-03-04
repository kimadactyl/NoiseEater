require_relative "../../NoiseEater"
 
require "capybara"
require "capybara/cucumber"
require 'capybara/rspec'
require "rspec" 
require "launchy"

Capybara.app = NoiseEater
include RSpec::Matchers
