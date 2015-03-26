require "data_mapper"
require "carrierwave"
require "carrierwave/datamapper"
# require "./config/settings"
require $DBGEM

# DataMapper::Logger.new(STDOUT, :debug)
DataMapper::setup(:default, $DBSTRING)

class AudioUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "public/audio/#{model.id}/"
  end

  def extensions_white_list
    %w(wav)
  end

  def move_to_store
    true
  end
end

class Audio
  include DataMapper::Resource
  # Unique key
  property :id, Serial
  # Optional description
  property :description, Text
  # Email for validation
  property :email, Text, :required => true
  # What to detect for
  property :detection, Enum[:wind, :mic, :distortion]
  # Creation time and completion time
  property :created_at, DateTime
  property :completed_at, DateTime
  # Unique string needed to validate
  property :validationstring, String
  # Has the file been validated by clicking the email link?
  # Defaults to true in case server is restarted with this setting changed
  property :validated, Boolean, :default => true
  # Has the file been processed?
  property :processed, Boolean, :default => false
  # Was the file processed successfully? 0 == yes, other values for error codes
  property :success, Boolean, :default => false
  # Uploader gizmo
  mount_uploader :source, AudioUploader
end

# DataMapper.auto_migrate!
DataMapper.finalize
