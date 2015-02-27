require "eventmachine"
require "sinatra/base"
require "audio_waveform"
require "tilt/erb"
require "./models"
require "./fileprocessor"

$queue = ProcessorQueue.new

def run(opts)

  # Start he reactor
  EM.run do

    # define some defaults for our app
    server  = opts[:server] || 'thin'
    host    = opts[:host]   || '0.0.0.0'
    port    = opts[:port]   || '9393'
    web_app = opts[:app]

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    # NOTE that we have to use an EM-compatible web-server. There
    # might be more, but these are some that are currently available.
    unless ['thin', 'hatetepe', 'goliath'].include? server
      raise "Need an EM webserver, but #{server} isn't"
    end

    # Start the web server. Note that you are free to run other tasks
    # within your EM instance.
    Rack::Server.start({
      app:    dispatch,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })

    $queue.next_ticket
  end
end

class AudioWebsite < Sinatra::Base

  configure do
    set :threaded, true
  end

  get "/" do
      erb :index
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
      erb :error
    elsif(@a.processed == true)
      erb :report
    elsif(@a.processed == false)
      erb :processing, :locals => {:queue => $queue, :a => @a}
    end
  end

  # run!
end

run app: AudioWebsite.new
