$:.unshift(__FILE__, ".")
require "sinatra/base"
require "json"
require "mustache/sinatra"
require "audio_waveform"
require 'streamio-ffmpeg'
require "./models"
require "./fileprocessor"

$queue = ProcessorQueue.new

class NoiseEater < Sinatra::Base

  register Mustache::Sinatra
  require 'views/layout'

  set :mustache, {
    :views     => 'views/',
    :templates => 'templates/'
  }

  get "/" do
    mustache :index
  end

  post "/" do
    a = Audio.new
    a.source = params[:audio]
    a.email = params[:email]
    a.description = params[:description]
    # Selector for no output, wav, or mp3
    a.output = params[:output]
    a.processed = false
    a.created_at = Time.now
    a.save
    redirect "/report/#{a.id}"
  end

  get "/report/:id" do
    @a = Audio.get params[:id]
    if(!@a)
      mustache :error
    elsif(@a.processed == true)
      mustache :report, {}, :a => @a
    elsif(@a.processed == false)
      mustache :processing, {}, :queue => $queue
    end
  end

  # run!
end
