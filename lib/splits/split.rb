class Splits
  class Split < Struct.new(:name, :pb_time_duration)
    COLUMNS = [0, 25, 37, 49, 61]

    attr_accessor :time, :time_duration, :row, :is_current

  end
end
