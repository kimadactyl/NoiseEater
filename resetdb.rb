require './config/settings'
require './models'

$l = Logger.new $LOG, 'daily'
$l.level = Logger::INFO

$l.warn Audio.destroy ? "Database cleared" : "Error: Database not cleared!"
$l.warn `rm -fr ./public/audio/` ? "Audio directory cleared" : "Error: Audio directory not cleared!"
$l.warn Audio.auto_migrate! ? "Database reinitiated" : "Error: Database not reinitated!"