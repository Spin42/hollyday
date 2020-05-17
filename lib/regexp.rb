class Regexp
  DAYS_AND_DATES = /(monday|tuesday|wednesday|thursday|friday|tomorrow|today)|(\d{1,2}\/\d{1,2})/
  WEEK_DAYS = /monday|tuesday|wednesday|thursday|friday/
  DATES = /(\d{1,2}\/\d{1,2})/
  ENTRY_TYPE_DAYS_AND_MONTHS = /(pto|wfh|sick|afk)|\@(\w+)|(january|february|march|april|may|june|july|august|september|october|november|december)|(monday|tuesday|wednesday|thursday|friday|tomorrow|today)/
  AM_PM = /(morning|afternoon|am|pm)/
  DAYS_AND_TIMES = /(monday|tuesday|wednesday|thursday|friday|tomorrow|today)|(\d{1,2}\/\d{1,2})|(\d{1,2}:?\d{2}?)/
end
