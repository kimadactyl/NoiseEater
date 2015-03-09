$:.unshift(__FILE__, ".")
require "sinatra/base"
require "json"
require "mustache/sinatra"
require "audio_waveform"
require "securerandom"
require "./models"
require "./fileprocessor"

$queue = ProcessorQueue.new

class NoiseEater < Sinatra::Base

  register Mustache::Sinatra
  require 'views/layout'

  # Set env for Mustache
  set :mustache, {
    :views     => 'views/',
    :templates => 'templates/'
  }

  # Index page
  get "/" do
    mustache :index
  end

  # Post audio file
  post "/" do
    a = Audio.new
    a.source = params[:audio]
    a.email = params[:email]
    a.description = params[:description]
    # Selector for no output, wav, or mp3
    a.output = params[:output]
    # Make a random string to validate with
    a.validationstring = SecureRandom.hex
    a.created_at = Time.now
    a.save
    redirect "/report/#{a.id}"
  end

  # Report pages
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

  # Validate strings clicked in emails
  get "/validate/:key" do
    a = Audio.first(:validationstring => params[:key])
    if a
      a.validated = true
      a.save
      mustache :validated
    else
      not_found
    end
  end

  not_found do
    status 404
    mustache :notfound
  end

  run!
end
