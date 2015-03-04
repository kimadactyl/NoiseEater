class NoiseEater
  module Views
    class Report < Layout

      def description
        @a.description
      end

      def audio_source
        @a.id.to_s + "/"  + File.basename(@a.source.path)
      end

      def global_stats
        datafile = File.read("./public/audio/" + @a.id.to_s + "/" + "data.json")
        JSON.parse(datafile)["Global Stats"]
      end

      def time_history
        datafile = File.read("./public/audio/" + @a.id.to_s + "/" + "data.json")
        JSON.parse(datafile)["Time History"]
      end

    end
  end
end