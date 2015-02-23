require_relative "../../audiowebsite"
 
require "capybara"
require "capybara/cucumber"
require "rspec" 
 
World do
  Capybara.app = AudioWebsite
  include RSpec::Matchers
end