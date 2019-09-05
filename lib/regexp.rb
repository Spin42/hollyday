class Regexp
  DAYS_AND_DATES = /(monday|tuesday|wednesday|thursday|friday|tomorrow|today)|(\d{1,2}\/\d{1,2})/
  WEEK_DAYS = /monday|tuesday|wednesday|thursday|friday/
  DATES = /(\d{1,2}\/\d{1,2})/
  ENTRY_TYPE_AND_MONTHS = /(pto|wfh)|\@(\w+)|(january|february|march|april|may|june|july|august|september|october|november|december)/
end
