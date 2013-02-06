require 'io/console'
require 'colorize'

class Splits
  class UI
    def initialize(column_size)
      @column_size = [column_size, "FINAL".length].max
    end

    def wait_for_char &block
      loop do
        char = STDIN.getch
        abort if char.ord == 3 # CTRL-C
        next unless char =~ /[a-zA-z]/ || char.ord == 32
        char = "SPACE" if char.ord == 32
        yield char
      end
    end

    def ready(title, split_names, pb_start_time = nil, pb_splits = nil)
      puts "READY TO PLAY THE FOLLOWING GAME:".colorize(:yellow)
      puts
      puts title
      puts '-' * title.length
      split_names.each do |split_name|
        print split_name.ljust(@column_size)
        if pb_splits
          pb_split_time = pb_splits[split_name]
          pb_time_diff = pb_split_time - pb_start_time
          pb = formatted_time_duration(pb_time_diff)
          print "\t", "(PB: #{pb})"
        end
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

    def split(name, time_diff, pb_time_diff = nil)
      line = [name.ljust(@column_size), "\t", formatted_time_duration(time_diff)]
      if pb_time_diff
        differential = time_diff - pb_time_diff
        negative = differential < 0
        differential *= -1 if negative
        line << "\t"
        line << (negative ? '-' : '+')
        line << formatted_time_duration(differential)
      end
      line = line.join
      if pb_time_diff
        if negative
          line = line.colorize(:green)
        else
          line = line.colorize(:red)
        end
      end

      puts line
    end

    def finish(time_diff, results_file)
      puts
      print ["FINAL".ljust(@column_size), "\t", formatted_time_duration(time_diff)].join.colorize(:yellow)
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

    private

    def formatted_time_duration time_diff
      seconds = time_diff.round(1)

      seconds_left = seconds.to_i
      hours, seconds_left = seconds_left.divmod(3600)
      minutes, seconds_left = seconds_left.divmod(60)

      "%02d:%02d:%04.1f" % [hours, minutes, seconds]
    end

  end
end
