$:.unshift(__FILE__, ".")
require "sinatra/base"
require "json"
require "mustache/sinatra"
require "audio_waveform"
require "securerandom"
require 'mail'
require 'colorize'
require 'fileutils'
require "./config/settings"
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
    # Basic info
    a.source = params[:audio]
    a.email = params[:email]
    a.description = params[:description]
    # Selector for no output, wav, or mp3, and segments or muted waveform
    # a.output = params[:output]
    # a.type = params[:type]
    # What detection type?
    a.detection = params[:detection]
    # Make a random string to validate with
    a.validationstring = SecureRandom.hex
    # Timestamp it at upload
    a.created_at = Time.now
    # Email the user unless validation is disabled
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
  get "/report/:validationstring/output" do
    @a = Audio.first(:validationstring => params[:key])
    if(!@a)
      mustache :error
    elsif(@a.processed == true)
      mustache :report, {}, :a => @a
    elsif(@a.processed == false)
      mustache :processing, {}, :queue => $queue
    end
  end

  post "/report/:validationstring" do
    # Generate an output file from a report
    a = Audio.first(:validationstring => params[:key])

    # Regions or whole file, and a threshold, passed to this section
    type = params[:type]
    thresh = params[:thresh]
    format = params[:output]

    # Sanity check
    unless(a && type && thresh && a.completed_at)
      halt mustache :error
    end

    # Read our JSON
    dir = File.dirname(input)
    output = File.dirname(a.source.path)

    # Select the file to process from
    case format
    when "mp3"
      input = output + "/input.mp3"
    when "ogg"
      input = output + "/input.ogg"
    when "source"
      input = a.source.path
    end

    # TODO: read threshold data properly
    data = File.read("#{output}/data.json")
    regions = JSON.parse(data)["Wind free regions"]

    if(type == "regions")
      # Make a directory
      FileUtils.mkdir_p("#{output}/regions")

      # For each region, write one file in regions dir
      puts "#{a.id}: Writing regions... ".colorize(:yellow)
      regions.each_with_index do |region, idx|
        print "#{idx},"
        `#{$FFMPEG} -i #{input} -ss #{region["s"]} -t #{region["e"]} -v quiet #{output}/regions/region-#{idx}.wav -y`
      end
      puts "#{a.id}: Regions written.".colorize(:green)

      # TODO: Zip regions

    elsif(type == "mute")
      # Single file with muted sections
      regions.each do |regions|
        filter << "volume=enable='between(t,#{region["s"]},#{region["e"]}':volume=0, "
      end
      puts "#{a.id}: Regions written.".colorize(:green)
      `#{$FFMPEG} -i #{input} -af #{filter}`
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
      mail.delivery_method :sendmail
      mail.deliver
    end
  end

end