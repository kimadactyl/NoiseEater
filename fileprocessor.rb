class ProcessorQueue

  def initialize
    # Start the queue
    puts ("Queue starting on " + $DOMAIN + " as " + $FROM_EMAIL).colorize(:green)
    puts $REQUIRE_VALIDATION ? "Validation is enabled".colorize(:green) : "Validation is disabled".colorize(:red)
    puts $SEND_CONFIRMATION ? "Email confirmation is enabled".colorize(:green) : "Email confirmation is disabled".colorize(:red)
    # print ("ffmpeg path is " + `which ffmpeg`).colorize(:green)
    # print ("ffprobe path is " + `which ffprobe`).colorize(:green)
    @running = true

    # Caution: behaviour here may still return nil for *new* wind-noise database
    # ie: where there is *not even an initial ticket*
    # But otherwise last ticket is given by next_ticket, and they're compared to
    # control processing behaviour now.
    @ticket = next_ticket

    Thread.new { loop }
  end

  def loop
    while true do
      if next_ticket == last_ticket
        # The queue is at its end
        # Sleep for 5 seconds then try again
        sleep 5
      else
        # If there's a ticket to process, go do that
        @ticket = next_ticket
        t = @ticket.id
        puts "#{t}: Next ticket".colorize(:green)
        process(t)
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
    if ticket
      return ticket
    else
      # If not, return the last_ticket as current queue index
      return last_ticket
    end
  end

  def last_ticket
  # Return the last processed file on the queue
    return Audio.last(:processed => true)
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
        unless File.extname(a.source.path) == ".mp3"
          puts "#{a.id}: Writing mp3"
          `#{$FFMPEG} -i #{a.source.path} -codec:a libmp3lame -qscale:a 2 #{output}/input.mp3 -y`
        end
        unless File.extname(a.source.path) == ".ogg"
          puts "#{a.id}: Writing ogg"
          `#{$FFMPEG} -i #{a.source.path} -codec:a libvorbis -qscale:a 7 #{output}/input.ogg -y`
        end

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

  def time_to_process audio_id
    # Estimated time to end of queue.
    pending = Audio.all(:processed => 'false', :id.lte => audio_id)
    time = 0.0
    pending.each do |audio|
      time += $TIME_PER_KB * audio.source.size / 1024
    end
    return time
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
