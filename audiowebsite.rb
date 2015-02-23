require "sinatra/base"
require "./models"
 
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
      redirect "/thankyou"
    end

    get "/thankyou" do
      erb :thankyou
    end
end