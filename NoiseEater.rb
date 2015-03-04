$:.unshift(__FILE__, ".")
require "sinatra/base"
require "mustache/sinatra"
require "audio_waveform"
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
      mustache :report
    elsif(@a.processed == false)
      mustache :processing, :locals => {:queue => $queue, :a => @a}
    end
  end

  run!
end
