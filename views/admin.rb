class NoiseEater
  module Views
    class Admin < Layout
      def get_all
        Audio.all
      end
    end
  end
end