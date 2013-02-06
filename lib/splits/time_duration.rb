class TimeDuration
  attr_reader :hours, :minutes, :seconds, :diff_in_seconds

  def initialize(diff_in_seconds)
    @diff_in_seconds = diff_in_seconds
    whole_seconds = @diff_in_seconds.to_i
    part_seconds = @diff_in_seconds - @diff_in_seconds.to_i

    @hours, whole_seconds = whole_seconds.divmod(3600)
    @minutes, whole_seconds = whole_seconds.divmod(60)
    @seconds = whole_seconds + part_seconds
  end

  def to_s
    "%02d:%02d:%04.1f" % [@hours, @minutes, @seconds]
  end

end
