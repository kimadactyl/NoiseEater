class NoiseEater
  module Views
    class Report < Layout
      def description
        @a.description
      end

      def source
        @a.id.to_s + "/" + File.basename(@a.source.path)
      end
    end
  end
end