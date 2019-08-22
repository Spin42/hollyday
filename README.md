### What's this?

This is a simple pto and wfh bot for multiple Slack teams.

### Run

```
bundle install
rake db:create db:migrate
foreman start
```

### Supported commands

```
help                           - get this helpful message
wfh [today|tomorrow|monday...] - log when you are working from home
pto|off from dd/mm to dd/mm    - log your personal time off
summary                        - shows summary for next 10 calendar days
```
