class DateUtils
  SHORT_FORMAT = "%d/%m"
  LONG_FORMAT  = "%A %B %d %Y"

  def self.closest_day(day_of_the_week, date=Date.today)
    if day_of_the_week > date.cwday
      date + (day_of_the_week - date.cwday)
    else
      date + 7 - (date.cwday - day_of_the_week)
    end
  end

  def self.extract_date_from_match match
    if match.first.nil? && !(match.last =~ Regexp::DATES).nil?
      date = Date::strptime(match.last, DateUtils::SHORT_FORMAT)
      if date < Date.today
        date + 1.year # We have jumped a year
      else
        date
      end
    elsif !match.first.nil?
      self.interpolate_date_from_string match.first
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
end
