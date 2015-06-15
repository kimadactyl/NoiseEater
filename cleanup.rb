require './config/settings'
require './models'
require 'date'
require 'fileutils'
require 'colorize'

$l = Logger.new $LOG, 'daily'
$l.level = Logger::INFO

$l.info "Cleanup: started"

# Cronjob activated script to clear out old files

old_files = Audio.all(:completed_at.lt => (Date.today - $DELETE_TIME), :expired => false)
not_validated_files = Audio.all(:completed_at.lt => (Date.today - $DELETE_IF_NOT_VALIDATED), :validated => false,  :expired => false)

all_files = old_files + not_validated_files

if all_files.length > 0
  $l.info "Cleanup: running automated deletion"

  all_files.each do |file|
    $l.info "Cleanup: #{file.id}: Deleted"
    FileUtils.rm_rf("./public/audio/" + file.validationstring)
  end

  all_files.update(:expired => true)
else
  $l.info "Cleanup: Automated deletion ran, nothing to do."
end