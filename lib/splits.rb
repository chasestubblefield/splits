require 'yaml'

class Splits

  def initialize(options = {})
    options = {
      game: 'game.yml',
      pb: 'pb.yml',
      results: 'results.yml',
    }.merge!(options)

    game_data = YAML.load_file(options[:game])
    @has_pb = File.exists?(options[:pb])
    pb_data = @has_pb ? YAML.load_file(options[:pb]) : nil

    @title = game_data['title']
    @splits = game_data['splits'].map do |name|
      if pb_data && pb_data['splits'][name]
        pb_time_duration = TimeDuration.new(pb_data['splits'][name] - pb_data['start'])
      end
      Split.new(name, pb_time_duration)
    end.freeze

    @results_file = options[:results]

    UI.column_size = @splits.map(&:name).map(&:length).max
  end

  def run!
    UI.ready(@title, @splits)
    UI.wait_for_char do |char|
      case char
      when "SPACE"
        if finished?
          save!
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
    UI.start(@has_pb)
  end

  def split!
    split_time = Time.now
    time_duration = TimeDuration.new(split_time - @start_time)

    split = next_split
    split.time = split_time
    split.time_duration = time_duration

    UI.split(split)

    if next_split.nil?
      @finished = true
      UI.finish(time_duration, @results_file)
    end
  end

  def save!
    splits = @splits.inject({}) do |hash, split|
      hash[split.name] = split.time
      hash
    end
    results = {
      'title' => @title,
      'start' => @start_time,
      'splits' => splits,
    }

    File.open(@results_file, 'w') do |file|
      file.write results.to_yaml
    end
    UI.goodbye
  end

  def started?
    !@start_time.nil?
  end

  def finished?
    !@finished.nil?
  end

  private

  def next_split
    @splits.detect { |split| split.time.nil? }
  end
end

require 'splits/split'
require 'splits/time_duration'
require 'splits/ui'
