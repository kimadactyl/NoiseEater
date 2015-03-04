require "data_mapper"
require "dm-sqlite-adapter"
require "carrierwave"
require "carrierwave/datamapper"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/audio.db")

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
  property :id, Serial
  property :description, Text
  property :email, Text, :required => true
  property :processed, Boolean, :default => false
  property :created_at, DateTime
  property :output, Enum[:none, :wav, :mp3], :default => :none
  mount_uploader :source, AudioUploader
end

DataMapper.finalize