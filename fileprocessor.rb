class ProcessorQueue

  def initialize
    # Start the queue
    puts ("Queue starting on " + $DOMAIN + " as " + $FROM_EMAIL).colorize(:green)
    puts $REQUIRE_VALIDATION ? "Validation is enabled".colorize(:blue) : "Validation is disabled".colorize(:blue)
    puts $SEND_CONFIRMATION ? "Email confirmation is enabled".colorize(:green) : "Email confirmation is disabled".colorize(:green)
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
    # Run the windDet binary
    puts "#{a.id}: ./windDet -i #{input} -o #{output}/output -j #{output}/data.json".colorize(:green)
    # Run commmand and check exit status
    if system "./windDet -i #{input} -o #{output}/output -j #{output}/data.json"
      puts "#{a.id}: Processing completed successfully.".colorize(:green)
      # Mark it as complete in the database
      a.processed = true
      a.success = true
      if $SEND_CONFIRMATION
        # Confirm if requested
        send_confirmation_email(a.id)
        puts "#{a.id}: Sent confirmation email".colorize(:green)
      end
    else
      puts "#{a.id}: Processing unsuccessful.".colorize(:red)
      a.processed = true
      a.success = false
    end
    a.save
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

  def send_confirmation_email(id)
    a = Audio.get(id)
    link =  $DOMAIN + "/report/" + a.id.to_s

    mail = Mail.new do
      from $FROM_EMAIL
      subject 'NoiseEater: your request is completed'
      to a.email
      body 'Audio file processing complete. View the report on our website: ' + link
    end

    mail.deliver
  end

end



