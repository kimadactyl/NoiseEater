source "https://rubygems.org"

# Display
gem "sass", "~> 3.4.0"
gem "compass", "~> 1.0"

# Sinatra and templating
gem "sinatra", git: 'https://github.com/sinatra/sinatra.git'
gem "mustache-sinatra"

# Pretty output
gem "colorize"

# Database
gem "datamapper"
gem "json"

# File uploads
gem 'carrierwave'
gem 'carrierwave-datamapper', :require => 'carrierwave/datamapper'
gem 'fileutils'

# Audio processing
gem 'audio_waveform-ruby' # waveform generator

# Email server
gem 'mail'

# Webserver
gem "rack"

group :production do
  gem "dm-postgres-adapter"
  gem "dm-mysql-adapter"
end

# Test suite
group :development do
  gem "dm-sqlite-adapter"
  gem "cucumber"
  gem "capybara"
  gem "rspec"
  # gem "shotgun"
  # gem "capybara-webkit"
  # gem "launchy"
  # gem "poltergeist"
  # gem "phantomjs", :require => "phantomjs/poltergeist"
  # gem "database_cleaner"
  # gem "eventmachine"
end
