class NoiseEater
  module Views
    class Waitingtime < Layout
      def processing_now
        @qlength == 0
      end
      def redirect_now
        @redirect_now
      end
      def qlength
        @qlength
      end
      def qtime
        distance_in_minutes = (@qtime / 60).round
        case distance_in_minutes
          when 0          then "less than a minute"
          when 1          then "1 minute"
          when 2..45      then "#{distance_in_minutes} minutes"
          when 46..90     then "about 1 hour"
          when 90..1440   then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
          when 1441..2880 then "1 day"
          else                 "#{(distance_in_minutes / 1440).round} days"
        end
      end
    end
  end
end