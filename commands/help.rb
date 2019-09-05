class Help < SlackRubyBot::Commands::Base
  HELP = <<-EOS.freeze
```
Commands
--------
help                                - get this helpful message
wfh [arguments]                     - log when you are working from home
pto [arguments]                     - log your personal time off
sick [arguments]                    - log your sick leave
summary [wfh|pto|@user|month]       - shows summary for next 10 calendar days for type or user
entries                             - list your entries and allows you to delete them

[arguments] can be [tomorrow|today|monday|tuesday|...] or a single or range of dates [dd/mm]

```
  EOS
  def self.call(client, data, _match)
    client.say(channel: data.channel, text: HELP, as_user: false)
    logger.info "HELP: #{client.owner}, user=#{data.user}"
  end
end
