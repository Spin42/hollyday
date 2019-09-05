class DateUtils
  SHORT_FORMAT = "%d/%m"
  LONG_FORMAT  = "%A %B %d"

  def self.closest_day(day_of_the_week, date=Date.today)
    if day_of_the_week > date.cwday
      date + (day_of_the_week - date.cwday)
    else
      date + 7 - (date.cwday - day_of_the_week)
    end
  end

  def self.extract_date_from_match match
    if match.first.nil? && !(match.last =~ Regexp::DATES).nil?
      Date::strptime(match.last, DateUtils::SHORT_FORMAT)
    elsif !match.first.nil?
      case match.first
      when "today"
        Date.today
      when "tomorrow"
        Date.today+1.day
      else
        estimated_date = Date.parse(match.first)
        DateUtils.closest_day(estimated_date.cwday)
      end
    end
  end
end
