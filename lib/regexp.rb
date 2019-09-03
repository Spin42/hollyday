class Regexp
  DAYS_AND_DATES = /\b(monday|tuesday|wednesday|thursday|friday|tomorrow|today
    |\d{1,2}\/\d{1,2})\b/
  DATES = /(\d{1,2}\/\d{1,2})/
  ENTRY_TYPE_AND_MONTHS = /(pto|wfh)|\@(\w+)|(january|february|march|april|may
    |june|july|august|september|october|november|december)/
end
