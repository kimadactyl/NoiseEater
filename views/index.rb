class NoiseEater
  module Views
    class Index < Layout
      def audio
        Audio.all(:processed => true, :order => [:id.desc], :limit => 10)
      end
    end
  end
end