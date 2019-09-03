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
end
