require './config/settings'
require './models'
require 'date'
require 'fileutils'
require 'colorize'

# Cronjob activated script to clear out old files

old_files = Audio.all(:created_at.lt => (Date.today - $DELETE_TIME))
not_validated_files = Audio.all(:created_at.lt => (Date.today - $DELETE_IF_NOT_VALIDATED), :validated => false)

all_files = old_files + not_validated_files

if all_files.length > 0
  puts "Running automated deletion".yellow.on_red

  all_files.each do |file|
    puts "#{file.id}: Deleted".colorize(:red)
    FileUtils.rm_rf("./public/audio/" + file.validationstring)
  end

  all_files.destroy
else
  puts "Automated deletion ran, nothing to do.".yellow.on_red
end