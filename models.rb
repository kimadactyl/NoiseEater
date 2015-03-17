require "data_mapper"
require "carrierwave"
require "carrierwave/datamapper"
require "dm-sqlite-adapter"
require "dm-postgres-adapter"

settings = File.read("config/database")
DataMapper::setup(:default, settings)


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
  # Creation time
  property :created_at, DateTime
  # Unique string needed to validate
  property :validationstring, String
  # Has the file been validated by clicking the email link?
  property :validated, Boolean, :default => false
  # Has the file been processed?
  property :processed, Boolean, :default => false
  # Was the file processed successfully? 0 == yes, other values for error codes
  property :success, Boolean, :default => false
  # User's requested output format
  property :output, Enum[:none, :wav, :mp3], :default => :none
  # Uploader gizmo
  mount_uploader :source, AudioUploader
end

DataMapper.finalize