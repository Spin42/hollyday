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
help                                - get this helpful message
wfh [arguments]                     - log when you are working from home
pto [arguments]                     - log your personal time off
sick [arguments]                    - log your sick leave
summary [wfh|pto|@user|month]       - shows summary for next 10 calendar days for type or user
entries                             - list your entries and allows you to delete them

[arguments] can be [tomorrow|today|monday|tuesday|...] or a single or range of dates [dd/mm]
```

Holly also reacts to the wfh command by listening on any channels she was invited to.

### Contributing
Just fork it and send pull requests. We will review them.

### Version
1.1

### License
[MIT](https://github.com/Spin42/hollyday/blob/master/LICENSE)
