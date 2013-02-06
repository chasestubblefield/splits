require 'yaml'

class Splits

  def initialize(game_file, options = {})
    game_data = YAML.load_file(game_file)
    @title = game_data['title']
    @split_names = game_data['splits']

    @start_time = nil
    @end_time = nil
    @splits = {}

    if options[:pb]
      pb_data = YAML.load_file(options[:pb])
      @pb_start_time = pb_data['start']
      @pb_end_time = pb_data['end']
      @pb_splits = pb_data['splits']
    end

    @results_file = options[:results] || 'results.yml'

    longest_split = @split_names.map(&:length).max
    @ui = UI.new(longest_split)
  end

  def run!
    @ui.ready(@title, @split_names, @pb_start_time, @pb_splits)
    @ui.wait_for_char do |char|
      case char
      when "SPACE"
        if finished?
          write_results!
          @ui.goodbye
          exit
        elsif started?
          split!
        else
          start!
        end
      end
    end
  end

  def start!
    @start_time = Time.now
    @ui.start(!@pb_splits.nil?)
  end

  def split!
    split_time = Time.now
    split_name = next_split

    @splits[split_name] = split_time

    time_diff = split_time - @start_time

    if @pb_splits
      pb_split = @pb_splits[split_name]
      pb_time_diff = pb_split - @pb_start_time
    end

    @ui.split(split_name, time_diff, pb_time_diff)

    # finished!
    if next_split.nil?
      @end_time = split_time
      @ui.finish(time_diff, @results_file)
    end
  end

  def write_results!
    results = {
      'title' => @title,
      'start' => @start_time,
      'end' => @end_time,
      'splits' => @splits,
    }

    File.open(@results_file, 'w') do |file|
      file.write results.to_yaml
    end
  end

  def started?
    !@start_time.nil?
  end

  def finished?
    !@end_time.nil?
  end

  private

  def next_split
    @split_names.detect { |split_name| @splits[split_name].nil? }
  end
end

require 'splits/ui'
