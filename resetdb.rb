require './config/settings'
require './models'

puts Audio.destroy ? "Database cleared" : "Error: Database not cleared!"
puts `rm -fr ./public/audio/` ? "Audio directory cleared" : "Error: Audio directory not cleared!"
puts Audio.auto_migrate! ? "Database reinitiated" : "Error: Database not reinitated!"