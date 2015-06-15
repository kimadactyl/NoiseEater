class NoiseEater
  module Views
    class Report < Layout
      def id
        @a.id.to_s
      end
      
      def description
        @a.description
      end

      def validationstring
        @a.validationstring
      end

      def audio_source
        @a.validationstring + "/"  + File.basename(@a.source.path)
      end

      def global_stats
        @json["Global Stats"]
      end

      def time_history
        @json["Time History"].to_json
      end

      def location
        @location
      end

      def feedbackrating
        @a.feedbackrating ||= 50
      end

      def feedbacktext  
        @a.feedbacktext
      end

      def is_not_example
        @location == "audio"
      end

      def algo
        case @a.detection
          when :wind
            return "Wind"
          when :mic
            return "Handling"
          when :distortion
            return "Distortion"
        end
      end
    end
  end
end