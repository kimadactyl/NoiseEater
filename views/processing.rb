class NoiseEater
  module Views
    class Processing < Layout
      def queue_position
        if $queue.current_ticket
          p @a.id - $queue.current_ticket.id
          @a.id - $queue.current_ticket.id
        else
          0
        end
      end
    end
  end
end
