class ProcessorQueue

  def initialize
    # Start the queue
    puts ("Queue starting on " + $DOMAIN + " as " + $FROM_EMAIL).colorize(:green)
    puts $REQUIRE_VALIDATION ? "Validation is enabled".colorize(:green) : "Validation is disabled".colorize(:red)
    puts $SEND_CONFIRMATION ? "Email confirmation is enabled".colorize(:green) : "Email confirmation is disabled".colorize(:red)
    # print ("ffmpeg path is " + `which ffmpeg`).colorize(:green)
    # print ("ffprobe path is " + `which ffprobe`).colorize(:green)
    @running = false
    Thread.new { loop }
  end

  def loop
    while true do
      if next_ticket && !@running
        # If there's a ticket to process, go do that
        puts "#{next_ticket}: Next ticket".colorize(:green)
        # Stop doing this until it's done
        @running = true
        process(next_ticket)
        @running = false
      else
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
    if ticket
      return ticket.id
    else
      return false
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

      # Detection type?
      case a.detection
        when :wind
          det = $WINDDET
          workdir = "wind"
        when :distortion
          det = $DISTDET
          workdir ="distortion"
        when :mic
          det = $MICDET
          workdir = "mic"
      end

      # Timestamp for estimates
      start_time = Time.now
      # Log that we got this far
      puts "#{a.id}: #{det} -i #{input} -j #{output}/data.json".colorize(:yellow)
      # Launch process
      pid = spawn("#{det} -i #{input} -j #{output}/data.json")
      # Wait here for a response
      Process.waitpid(pid, 0)

      # Check exist status of last process
      if $?.success?
        # We did it!
        processing_time = Time.now - start_time
        puts "Completed"
        puts "#{a.id}: Processing completed successfully, took #{processing_time}s.".colorize(:green)

        # Sanitise json
        data = File.open("#{output}/data.json", "r")
        data = data.read
        data = data.gsub(/nan|-nan|inf|-inf/, "0")
        File.write("#{output}/data.json", data)

        # Write waveform data. -b 8 is critical for peaks.js to work with the data.
        if system "#{$AUDIOWAVEFORM} -i #{input} -o #{output}/waves.dat -b 8"
          puts "#{a.id}: Generated waveform data".colorize(:green)
        else
          puts "#{a.id}: Waveform generation failed! #{$AUDIOWAVEFORM} -i #{input} -o #{output}/waves.dat -b 8".colorize(:red)
        end

        # Convert it to an mp3 and ogg for playback
        if File.extname(a.source.path) == ".mp3"
          puts "#{a.id}: Already mp3, creating symlink"
          File.symlink(a.source.path, output + "/input.mp3")
        else
          puts "#{a.id}: Writing mp3"
          `#{$FFMPEG} -i #{a.source.path} -codec:a libmp3lame -qscale:a 2 #{output}/input.mp3 -y`
        end

        if File.extname(a.source.path) == ".ogg"
          puts "#{a.id}: Already ogg, creating symlink"
          File.symlink(a.source.path, output + "/input.ogg")
        else
          puts "#{a.id}: Writing ogg"
          `#{$FFMPEG} -i #{a.source.path} -codec:a libvorbis -qscale:a 7 #{output}/input.ogg -y`
        end

        # Mark it as complete in the database
        a.completed_at = Time.now
        a.processingtime = processing_time
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
  end


  def send_confirmation_email(a)
    link =  $DOMAIN + "/report/" + a.validationstring

    mail = Mail.new do
      from $FROM_EMAIL
      subject 'NoiseEater: your request is completed'
      to a.email
      body 'Audio file processing complete. View the report on our website: ' + link
    end
    mail.delivery_method $MAIL_PARAMS
    mail.deliver
  end

end
