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
    # Ensure one file per user by redirecting if the queue finds
    # May need to switch :processed for :success
    if Audio.all(:email => params[:email], :processed => false).length > 1
      # TODO: Change this for preferred error message format
      redirect "/onefileperuser.html"
      return
    end

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
  get "/report/:key" do
    # If validation is on, use that as the key, if not just use the ID
    if $REQUIRE_VALIDATION
      @a = Audio.first(:validationstring => params[:key])
    else
      @a = Audio.get(params[:key])
    end
    if(!@a)
      mustache :error
    elsif(@a.processed == true)
      datafile = File.read("./public/audio/" + @a.id.to_s + "/" + "data.json")
      @json = JSON.parse(datafile)
      mustache :report
    elsif(@a.processed == false)
      mustache :processing, {}, :queue => $queue
    end
  end

  post "/report/:key" do
    # Generate an output file from a report
    @a = Audio.get(params[:key])

    # Regions or whole file, and a threshold, passed to this section
    type = params[:type]
    format = params[:format]
    # JSON array of our regions
    # puts params[:regions]
    regions = JSON.parse(params[:regions])

    # Sanity check
    unless(@a && type && regions && format)
      halt mustache :error
    end

    puts "#{@a.id}: Output file request received".colorize(:green)

    # Read our JSON
    dir = File.dirname(@a.source.path)

    # Select the file to process from
    # Using this as the input format to cut down on conversions needed
    case format
    when "mp3"
      input = dir + "/input.mp3"
      ext = "mp3"
    when "ogg"
      input = dir + "/input.ogg"
      ext = "ogg"
    when "source"
      input = a.source.path
      ext = File.extname(a.source.path)
    end

    # Same whichever format
    response.headers['content_type'] = "application/octet-stream"

    if(type == "zip")
      # Make a directory
      FileUtils.mkdir_p("#{dir}/regions")

      # TODO: delete already existing files

      # For each region, write one file in regions dir
      print "#{@a.id}: Writing regions... ".colorize(:yellow)
      regions.each_with_index do |region, idx|
        print "#{idx},"
        `#{$FFMPEG} -i #{input} -ss #{region["s"]} -t #{region["e"]} -v quiet #{dir}/regions/region-#{idx}.#{ext} -y`
      end

      # Write the zip file. --filesync overwrites rather than adds in extra files. --junk-paths removes dir info
      `zip --filesync --junk-paths #{dir}/regions.zip #{dir}/regions/*.#{ext}`
      puts "zip #{dir}/regions.zip #{dir}/regions/*.#{ext}"
      puts "\n#{@a.id}: Regions written.".colorize(:green)

      # Send to user
      attachment("#{@a.description}-noise-free-regions.zip")
      response.write(File.read("#{dir}/regions.zip"))

    elsif(type == "mute")
      # Single file with muted sections
      # 1. Invert the regions to give sections with noise not without noise
      iregions = []
      regions.each_with_index do |region, idx|
        # Our first region starts at ether the end of the last region, or zero
        if idx > 0
          istart = regions[idx - 1]["e"]
        else
          istart = 0
        end
        # Get the start pointer of the first region and set as the end of our first noisy region
        iend = region["s"]
        # In case start and end are zero
        unless istart == iend
          iregions.push "s" => istart, "e" => iend
        end
      end
      # Now mute the inverted regions
      if iregions.length > 0
        filter = []
        iregions.each do |region|
          filter.push "volume=enable='between(t,#{region["s"]},#{region["e"]})':volume=0"
        end
        filter = '"' + filter.join(", ") + '"'
        `#{$FFMPEG} -i #{input} -af #{filter} -v quiet #{dir}/output.#{ext} -y`
        puts "#{@a.id}: Muted file #{dir}/output.#{ext} written.".colorize(:green)

        # Send file
        attachment("#{@a.description}-with-regions-muted.#{ext}")
        response.write(File.read("#{dir}/output.#{ext}"))
        puts "#{@a.id} Muted file sent"
      else
        # TODO: handle if no regions exist
      end
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
