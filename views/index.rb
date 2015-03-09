class NoiseEater
  module Views
    class Index < Layout
      def list_start
        Audio.first(:processed => true, :order => [:id.desc]) ? Audio.first(:processed => true, :order => [:id.desc]).id : false
      end
      def audio
        Audio.all(:processed => true, :order => [:id.desc], :limit => 10)
      end
    end
  end
end