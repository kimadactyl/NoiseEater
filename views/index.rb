class NoiseEater
  module Views
    class Index < Layout
      def list_start
        Audio.first(:processed => true, :order => [:id.desc]).id
      end
      def audio
        Audio.all(:processed => true, :order => [:id.desc], :limit => 10)
      end
    end
  end
end