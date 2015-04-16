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

    end
  end
end