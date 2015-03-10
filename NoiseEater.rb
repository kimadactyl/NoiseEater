$:.unshift(__FILE__, ".")
require "sinatra/base"
require "json"
require "mustache/sinatra"
require "audio_waveform"
require "securerandom"
require 'mail'
require 'colorize'
require "./models"
require "./fileprocessor"

$DOMAIN = "http://localhost:4567"
$FROM_EMAIL = "Noise Eater <noreply@noiseater.com>"
$REQUIRE_VALIDATION = false
$SEND_CONFIRMATION = true

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
    # Email the user unless we turn off validation
    if $REQUIRE_VALIDATION 
      a.save
      puts "#{a.id}: Emailing #{a.email} a validation link".colorize(:blue)
      send_validation_email(a.id)
    else 
      a.validated = true
      a.save
      puts "#{a.id}: Uploaded, validation disabled".colorize(:blue)
    end
    # Redirect to report page
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
    @a = Audio.first(:validationstring => params[:key])
    if @a
      @a.validated = true
      @a.save
      puts "#{@a.id}: Validation link clicked. Redirecting...".colorize(:blue)
      mustache :validated, {}, :a => @a
    else
      not_found
    end
  end

  not_found do
    status 404
    mustache :notfound
  end

  helpers do
    def send_validation_email(id)
      a = Audio.get(id)
      link =  $DOMAIN + '/validate/' + a.validationstring

      mail = Mail.new do
        from $FROM_EMAIL
        subject 'NoiseEater: approve your upload now'
        to a.email
        body 'Thanks for your submission. Click here to start processing your file: ' + link
      end

      mail.deliver
    end
  end

  run!
end

