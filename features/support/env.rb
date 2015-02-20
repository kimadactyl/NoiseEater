require_relative "../../audiowebsite"
 
require "capybara"
require "capybara/cucumber"
require "rspec" 
 
World do
  Capybara.app = AudioWebsite
 
  include Capybara::DSL
  include RSpec::Matchers
end