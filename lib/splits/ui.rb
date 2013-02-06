require 'io/console'
require 'colorize'

class Splits
  module UI
    extend self
    class << self
      attr_accessor :column_size
    end
    self.column_size = 20

    def wait_for_char &block
      loop do
        char = STDIN.getch
        abort if char.ord == 3 # CTRL-C
        next unless char =~ /[a-zA-z]/ || char.ord == 32
        char = "SPACE" if char.ord == 32
        yield char
      end
    end

    def ready(title, splits)
      puts "READY TO PLAY THE FOLLOWING GAME:".colorize(:yellow)
      puts
      puts title
      puts '-' * title.length
      splits.each do |split|
        print split.name.ljust(@column_size)
        print "\t", "(PB: #{split.pb_time_duration.to_s})" if split.pb_time_duration
        puts
      end
      puts
      puts "PRESS SPACE TO START".colorize(:yellow)
    end

    def start(include_pb = false)
      puts "\nGOOD LUCK!\n".colorize(:green)
      print "Split".ljust(@column_size), "\t", "Time".ljust(10)
      if include_pb
        print "\t", "Diff".ljust(11)
      end
      puts
      print '-' * @column_size, "\t", '-' * 10
      if include_pb
        print "\t", '-' * 11
      end
      puts
    end

    def split(split)
      line = [split.name.ljust(@column_size), "\t", split.time_duration.to_s]
      color = nil
      if split.pb_time_duration
        line << "\t"
        diff = split.pb_time_duration.diff_in_seconds - split.time_duration.diff_in_seconds
        if diff < 0
          color = :red
          diff *= 1
          line << "-"
        else
          color = :green
          line << "+"
        end
        line << TimeDuration.new(diff).to_s
      end
      puts line.join.colorize(color)
    end

    def finish(final_time, results_file)
      puts
      print ["FINAL".ljust(@column_size), "\t", final_time.to_s].join.colorize(:yellow)
      puts
      puts
      print "PRESS SPACE TO WRITE RESULTS TO #{results_file}".colorize(:yellow)
      if File.exists?(results_file)
        print " (file exists!)".colorize(:yellow)
      end
      puts
    end

    def goodbye
      puts "\nTHANKS FOR PLAYING!".colorize(:yellow)
    end

  end
end
