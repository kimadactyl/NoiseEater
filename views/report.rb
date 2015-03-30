class NoiseEater
  module Views
    class Report < Layout

      def id
        @a.id.to_s
      end

      def description
        @a.description
      end

      def audio_source
        @a.id.to_s + "/"  + File.basename(@a.source.path)
      end

      def global_stats
        @json["Global Stats"]
      end

      def time_history
        @json["Time History"]
      end

      def wind_free_regions
        @json["Wind free regions"]
      end
    end
  end
end