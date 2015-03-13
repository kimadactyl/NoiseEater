db = URI.parse(ENV['DATABASE_URL'])

configure :development do
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/audio.db")
end

configure :production do
	DataMapper::setup(:default, "postgres://#{$DBUSER}:#{$DBPASSWORD}@localhost/noise_eater")
end