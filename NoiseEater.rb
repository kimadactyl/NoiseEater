$:.unshift(__FILE__, ".")
require "sinatra/base"
require "json"
require "mustache/sinatra"
require "audio_waveform"
require "securerandom"
require "mail"
require "fileutils"
require "date"
require "ostruct"
require "logger"
require "./config/settings"
require "./models"
require "./fileprocessor"


$l = Logger.new $LOG, 'daily'
$l.level = Logger::INFO
$queue = ProcessorQueue.new

class NoiseEater < Sinatra::Base

  register Mustache::Sinatra
  require 'views/layout'

  # Set env for Mustache
  set :mustache, {
    :views     => 'views/',
    :templates => 'templates/'
  }

  # === Index Routes === #
  get "/" do
    # Homepage
    mustache :index
  end

  post "/" do
    # Post audio file

    # Ensure one file per user by redirecting if the queue finds
    # May need to switch :processed for :success
    if Audio.all(:email => params[:email], :processed => false).length > 1 && $ONE_FILE_PER_USER
      redirect "/error/one-file-per-user"
    end

    # Probe the file for error and input format
    filename = params[:audio][:tempfile].path
    probe = `#{$FFPROBE} -show_error -show_streams -v quiet #{filename}`

    # Is it a valid format?
    if probe.include? "[ERROR]"
      $l.warn "Uploaded file is not in a valid format. Aborting."
      # TODO: delete any temp files
      redirect "/error/file-not-valid"
    end

    a = Audio.new
    # Basic info
    a.source = params[:audio]
    a.email = params[:email]
    a.description = params[:description]
    # Length, using probe we already did and some regex
    a.filelength = probe.match('^duration=(\d+.?\d+)')[1]
    # What detection type?
    a.detection = params[:detection]
    # Make a random string to validate with
    a.validationstring = SecureRandom.hex
    # Timestamp it at upload
    a.created_at = Time.now
    # Email the user unless validation is disabled
    if $REQUIRE_VALIDATION
      a.validated = false
      a.save
      $l.info "#{a.id}: Emailing #{a.email} a validation link"
      send_validation_email(a.id)
      redirect "/thankyou"
    else
      a.validated = true
      a.save
      $l.info "#{a.id}: Uploaded, validation disabled"
      redirect "/report/#{a.id}"      
    end
  end

  #  === Report Routes === #

  get "/report/:key" do
    # View report 
    @a = get_audio params[:key]
    @location = "audio"
    if(!@a)
      not_found
    elsif(@a.processed == true)
      datafile = File.read("./public/audio/" + @a.validationstring + "/" + "data.json")
      @json = JSON.parse(datafile)
      mustache :report
    elsif(@a.processed == false)
      mustache :processing
    end
  end

  get "/example/:key" do
    # Load these manually
    key = params[:key]
    case key
      when "wind-cows"
        desc = "Wind detection: Cows mooing"
      when "wind-birds"
        desc = "Wind detection: Birdsong"
      when "wind-didgeridoo"
        desc = "Wind detection: Didgeridoo"
      when "dist-metro-musica"
        desc = "Distortion: Metro Musica"
      when "dist-ambulance"
        desc = "Distortion: Ambulance"
      when "dist-sheep-helicopter"
        desc = "Distortion: Sheep and Helicopter"
      else
        not_found
    end
    # Not very DRY, should probably abstract
    datafile = File.read("./public/examples/" + key + "/" + "data.json")
    @json = JSON.parse(datafile)

    # Make a fake object
    @a = OpenStruct.new
    @a.description = desc
    @a.validationstring = key
    @location = "examples"
    mustache :report
  end

  post "/report/:key" do
    # Generate an output file from a report
    @a = Audio.first(:validationstring => params[:key])
    # Regions or whole file, and a threshold, passed to this section
    type = params[:type]
    format = params[:format]
    # JSON array of our regions
    regions = JSON.parse(params[:regions])

    # Sanity check
    unless(@a && type && regions && format)
      redirect "/error/couldnt-generate-output"
    end

    $l.info "#{@a.id}: Output file request received"

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
      # Delete last attempt
      FileUtils.rm_rf("#{dir}/regions")
      # Make a directory
      FileUtils.mkdir_p("#{dir}/regions")

      # TODO: delete already existing files

      # For each region, write one file in regions dir
      print "#{@a.id}: Writing regions... "
      regions.each_with_index do |region, idx|
        print "#{idx},"
        `#{$FFMPEG} -i #{input} -ss #{region["s"]} -t #{region["e"]} -v quiet #{dir}/regions/region-#{idx}.#{ext} -y`
      end

      # Write the zip file. --filesync overwrites rather than adds in extra files. --junk-paths removes dir info
      `zip --filesync --junk-paths #{dir}/regions.zip #{dir}/regions/*.#{ext}`
      $l.debug "zip #{dir}/regions.zip #{dir}/regions/*.#{ext}"
      $l.info "\n#{@a.id}: Regions written."

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
        $l.info "#{@a.id}: Muted file #{dir}/output.#{ext} written."

        # Send file
        attachment("#{@a.description}-with-regions-muted.#{ext}")
        response.write(File.read("#{dir}/output.#{ext}"))
        $l.info "#{@a.id} Muted file sent"
      else
        # TODO: handle if no regions exist
      end
    end

  end

  # === Feedback form === #

  post "/feedback/:key" do
    @a = Audio.first(:validationstring => params[:key])
    @a.feedbackrating = params[:rating]
    @a.feedbacktext = params[:textfeedback]
    @a.save
    halt 200
  end


  # === Validate strings clicked in emails === #

  get "/validate/:key" do
    @a = Audio.first(:validationstring => params[:key])
    if @a
      @a.validated = true
      @a.save
      $l.info "#{@a.id}: Validation link clicked. Redirecting..."
      mustache :validated
    else
      not_found
    end
  end

  # === Admin routes === #

  get "/admin" do
    protected!
    mustache :admin
  end

  get "/admin/delete/:id" do
    protected!
    a = Audio.get(params[:id])
    a.destroy
    FileUtils.rm_rf("#{Dir.pwd}/public/audio/#{a.validationstring}")
    $l.info "#{a.id}: Deleted on admin request"
    redirect "/admin"
  end

  # === AJAX routes === #

  get "/waitingtime/:id" do
    id = params[:id]
    audio = Audio.get(id)
    # First check if it's complete
    if audio.processed
      @redirect_now  = $REQUIRE_VALIDATION ? audio.validationstring : audio.id
    end
    # Then, get the queue length
    @qlength = Audio.count(:validated => true, :processed => false, :id.lt => id)
    # Can overextimate if people don't validate but doesn't really matter
    @qtime = Audio.sum(:filelength, :id.lte => id) * $TIME_PER_SECOND

    # No layout as it's an AJAX request
    mustache :waitingtime, :layout => false
  end

  #  === Static page routes === #

  get "/about" do
    mustache :about
  end

  get "/thankyou" do
    mustache :thankyou
  end

  get "/contact" do
    mustache :contact
  end

  get "/terms" do
    mustache :terms
  end

  # === Errors === #

  get "/error/:error" do
    case params[:error]
    when "file-not-valid"
      @title = "Error: File not valid"
      @body = "Your audio file was not in a valid format. Please contact us if you think this is in error."
    when "one-file-per-user"
      @title = "Error: One file per user"
      @body = "You may only have one file in the queue at once. Please wait, or cancel your existing requests."
    when "couldnt-generate-output"
      @title = "Error: Couldn't generate report"
      @body = "Your output could not be generated. Please contact us, this shouldn't happen!"
    else
      @title = "Error"
      @body = "Something happened without a specific error page. Please contact us and tell us what went wrong!"
    end
    mustache :error
  end

  not_found do
    status 404
    @title = "404: Page Not Found"
    @body = "We can't find that page. Sorry!"
    mustache :error
  end

  # === Helpers === #

  helpers do
    def send_validation_email(id)
      # Sends email to user
      a = Audio.get(id)
      link =  $DOMAIN + '/validate/' + a.validationstring

      mail = Mail.new do
        from $FROM_EMAIL
        subject 'NoiseEater: approve your upload now'
        to a.email
        body 'Thanks for your submission. Click here to start processing your file: ' + link
      end
      $MAIL_PARAMS
      mail.deliver
    end

    def get_audio(id)
      # Returns either the validation string or the id depending on if require validation is on
      $REQUIRE_VALIDATION ? Audio.first(:validationstring => id) : Audio.get(id)
    end

    # h/t http://www.sinatrarb.com/faq.html#auth
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', $ADMINPASSWORD]
    end
  end

end
