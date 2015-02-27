require "sinatra/base"
require "audio_waveform"
require "tilt/erb"
require "./models"
require "./fileprocessor"
 
class AudioWebsite < Sinatra::Base

  @queue = ProcessorQueue.new

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
      erb :processing       
    end
  end

  # run!
end
