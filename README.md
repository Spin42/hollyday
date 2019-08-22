### What's this?

This is a simple pto and wfh bot for multiple Slack teams.

### Run

```
bundle install
rake db:create db:migrate
foreman start
```

### Supported commands
You may address to Holly directly by using @ in a channel she was invited to or in direct message with the following commands:
```
help                           - get this helpful message
wfh [today|tomorrow|monday...] - log when you are working from home
pto|off from dd/mm to dd/mm    - log your personal time off
summary                        - shows summary for next 10 calendar days
```

Holly also reacts to the wfh command by listening on any channels she was invited to.
