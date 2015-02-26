require_relative "../../audiowebsite"
 
require "capybara"
require "capybara/cucumber"
require "rspec" 
require "launchy"
 
World do
  Capybara.app = AudioWebsite.new
  Capybara.javascript_driver = :webkit
  include RSpec::Matchers
end