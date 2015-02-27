require "sinatra/base"
require "audio_waveform"
require "tilt/erb"
require "./models"
require "./fileprocessor"

$queue = ProcessorQueue.new

class AudioWebsite < Sinatra::Base

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

  run!
end
