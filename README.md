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
help                                 - get this helpful message
wfh [today|tomorrow|monday...|dd/mm] - log when you are working from home
pto from dd/mm to dd/mm              - log your personal time off
summary [wfh|pto|@user]              - shows summary for next 10 calendar days for type or user
entries                              - list your entries and allows you to delete them
```

Holly also reacts to the wfh command by listening on any channels she was invited to.

### Contributing
Just fork it and send pull requests. We will review them.

### License
[MIT](https://github.com/Spin42/hollyday/blob/master/LICENSE)
