class NoiseEater
  module Views
    class Processing < Layout
      def queue_position
        $queue.current_ticket
      end
    end
  end
end