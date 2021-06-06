class DateUtils
  SHORT_FORMAT = "%d/%m"
  LONG_FORMAT  = "%A %B %d %Y"
  TIME = "%H:%M"

  def self.closest_day(day_of_the_week, date=Date.today)
    if day_of_the_week > date.cwday
      date + (day_of_the_week - date.cwday)
    else
      date + 7 - (date.cwday - day_of_the_week)
    end
  end

  def self.extract_date_from_match match
    if match[0].nil? && !(match[1] =~ Regexp::DATES).nil?
      date = Date::strptime(match[1], DateUtils::SHORT_FORMAT)
      if date < Date.today
        date + 1.year # We have jumped a year
      else
        date
      end
    elsif !match[0].nil?
      self.interpolate_date_from_string match[0]
    end
  end

  def self.extract_date_and_times_from_matches matches
    Time.zone = "Europe/Brussels"
    if matches.size == 3
      day = extract_date_from_match matches[0] || Date.today
      from = extract_hours_and_minutes_from_string matches[1][2]
      to = extract_hours_and_minutes_from_string matches[2][2]
      [Time.zone.local(day.year, day.month, day.day, from[0], from[1], 0).to_datetime,
        Time.zone.local(day.year, day.month, day.day, to[0], to[1], 0).to_datetime]
    elsif matches.size == 2
      day = Date.today
      from = extract_hours_and_minutes_from_string matches[0][2]
      to = extract_hours_and_minutes_from_string matches[1][2]
      [Time.zone.local(day.year, day.month, day.day, from[0], from[1], 0).to_datetime,
        Time.zone.local(day.year, day.month, day.day, to[0], to[1], 0).to_datetime]
    elsif matches.size == 1
      now = Time.zone.local.to_datetime
      to = extract_hours_and_minutes_from_string matches[0][2]
      [now, Time.zone.local(now.year, now.month, now.day, to[0], to[1], 0).to_datetime]
    end
  end

  def self.interpolate_date_from_string date_string
    case date_string
    when "today"
      Date.today
    when "tomorrow"
      Date.today+1.day
    else
      estimated_date = Date.parse(date_string)
      DateUtils.closest_day(estimated_date.cwday)
    end
  end

  def self.extract_hours_and_minutes_from_string time_string
    if time_string.include?(":")
      time_string.split(":").map(&:to_i)
    else
      [time_string.to_i, 0]
    end
  end
end
