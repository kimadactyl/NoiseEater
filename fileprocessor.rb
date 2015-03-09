require 'mail'

DOMAIN = "http://localhost:4567"
FROM_EMAIL = "noreply@noiseater.com"

class ProcessorQueue

  def initialize
    # Start the queue
    puts "Queue starting."
    @running = true
    @ticket = Audio.first(:processed => false)
    unless @ticket
      @ticket = Audio.last
    end
    Thread.new { loop }
  end

  def loop
    while true do
      if next_ticket == "no ticket"
        sleep 5
        # tick of of up to 5 seconds when the queue does empty itself to prevent
        # excessive loops during no data shouldn't be a dealbreaker?
      end
    end
  end

  def next_ticket
    # Find next unprocessed ticket sorted by number order
    ticket = Audio.first(:processed => false)
    if(ticket)
      # If there's a ticket to process, go do that
      @ticket = ticket.id
      puts "Next ticket: #{@ticket}"
      process(@ticket)
    else
      # If not, stop the queue
      # just skip a frame
      return "no ticket"
    end
  end

  def process(id)
    # Process a file given an ID
    a = Audio.get(id)
    puts "#{id}: Starting processing"
    input = a.source.path
    puts "Source path is #{input}. Starting..."
    output = File.dirname(input)
    # Run the windDet binary
    `./windDet -i #{input} -o #{output}/output -j #{output}/data.json`
    puts "#{a.id}: Processing complete"
    # Mark it as complete in the database
    a.processed = true
    a.save
    send_email(id)
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

  def send_email(id)
    a = Audio.get(id)
    link =  DOMAIN + '/validate/' + a.validationstring

    mail = Mail.new do
      from FROM_EMAIL
      to a.email
      subject 'NoiseEater: approve your upload now'
      body 'Thanks for your submission. Click here to start processing your file: ' + link
    end

    mail.deliver
  end

end



