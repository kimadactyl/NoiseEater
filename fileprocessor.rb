class ProcessorQueue

  def initialize
    # Start the queue
    puts ("Queue starting on " + $DOMAIN + " as " + $FROM_EMAIL).colorize(:green)
    puts $REQUIRE_VALIDATION ? "Validation is enabled".colorize(:blue) : "Validation is disabled".colorize(:blue)
    puts $SEND_CONFIRMATION ? "Email confirmation is enabled".colorize(:green) : "Email confirmation is disabled".colorize(:green)
    # print ("ffmpeg path is " + `which ffmpeg`).colorize(:green)
    # print ("ffprobe path is " + `which ffprobe`).colorize(:green)
    @running = true
    @ticket = Audio.first(:processed => false)
    unless @ticket
      @ticket = "no ticket"
    end
    Thread.new { loop }
  end

  def loop
    while true do
      if next_ticket == "no ticket"
        # Sleep for 5 seconds then try again
        sleep 5
      end
    end
  end

  def next_ticket
    # Find next unprocessed ticket sorted by number order
    if $REQUIRE_VALIDATION
      ticket = Audio.first(:processed => false, :validated => true)
    else
      ticket = Audio.first(:processed => false)
    end
    if(ticket)
      # If there's a ticket to process, go do that
      t = ticket.id
      puts "#{t}: Next ticket".colorize(:green)
      process(t)
    else
      # If not, stop the queue
      # just skip a frame
      return "no ticket"
    end
  end

  def process(id)
    # Process a file given an ID
    a = Audio.get(id)
    input = a.source.path
    output = File.dirname(input)

    # Probe the file for error and input format
    probe = `#{$FFPROBE} -show_error -show_streams -v quiet #{input}`
    # Tests we want to run this through
    tests = ["codec_name=pcm_s16le", "channels=1", "bits_per_sample=16", "sample_rate=44100"]

    # Is it a valid format?
    if probe.include? "[ERROR]"
        puts "#{a.id}: Audio file is not in a valid format. Aborting.".colorize(:red)
        a.processed = true
        a.success = false
    else
      # If so, is it a 16 bit, 44.1khz, mono wav file?
      unless tests.all? { |test| probe.include?(test) }
        # If not, convert to a valid format
        puts "#{a.id}: Not a 16 bit mono wav. Converting.".colorize(:green)
        puts "#{a.id}: ffmpeg -i #{input} -acodec pcm_s16le -ac 1 -ar 44100 #{output}/converted.wav".colorize(:yellow)
        `#{$FFMPEG} -i #{input} -acodec pcm_s16le -ac 1 -ar 44100 -v quiet #{output}/converted.wav -y`
        input = "#{output}/converted.wav"
      end
      # Then either way, process the file.
      # Run the windDet binary and check exit status
      puts "#{a.id}: #{$WINDDET} -i #{input} -j #{output}/data.json".colorize(:yellow)
      if system "#{$WINDDET} -i #{input} -j #{output}/data.json"
        puts "#{a.id}: Processing completed successfully.".colorize(:green)


        # Write waveform data. -b 8 is critical for peaks.js to work with the data.
        if system "#{$AUDIOWAVEFORM} -i #{input} -o #{output}/waves.dat -b 8" 
          puts "#{a.id}: Generated waveform data".colorize(:green) 
        else
          puts "#{a.id}: Waveform generation failed! #{$AUDIOWAVEFORM} -i #{input} -o #{output}/waves.dat -b 8".colorize(:red)
        end

        # Convert it to an mp3 and ogg for playback
        puts "#{a.id}: Writing mp3"
        `#{$FFMPEG} -i #{input} -codec:a libmp3lame -qscale:a 2 #{output}/input.mp3`
        puts "#{a.id}: Writing ogg"
        `#{$FFMPEG} -i #{input} -codec:a libvorbis -qscale:a 7 #{output}/input.ogg`

        # Mark it as complete in the database
        a.processed = true
        a.success = true

        if $SEND_CONFIRMATION
          # Confirm if requested
          send_confirmation_email(a)
          puts "#{a.id}: Sent confirmation email".colorize(:green)
        end
      else
        puts "#{a.id}: Processing unsuccessful.".colorize(:red)
        a.processed = true
        a.success = false
      end
    end
    
    # Save db record
    a.save
    puts "#{a.id}: Complete".colorize(:green)

    # Check for the next file
    next_ticket
  end

  def check_if_running
    # To be used post-form submit to check the queue is running.
    # If it's not, process it now.
    if @running == false
      @running = true
      next_ticket
    end
  end

  def current_ticket
    # Output current ticket status
    @ticket
  end

  def send_confirmation_email(a)
    link =  $DOMAIN + "/report/" + a.id.to_s

    mail = Mail.new do
      from $FROM_EMAIL
      subject 'NoiseEater: your request is completed'
      to a.email
      body 'Audio file processing complete. View the report on our website: ' + link
    end
    mail.delivery_method :sendmail
    mail.deliver
  end

end



