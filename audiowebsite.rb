require "sinatra/base"
 
class AudioWebsite < Sinatra::Base
    get "/" do
        erb :index
    end
     
    post "/" do
        @audio = params["audio"]
        @email = params["email"]
        erb :thankyou
    end
end