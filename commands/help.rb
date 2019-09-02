class Help < SlackRubyBot::Commands::Base
  HELP = <<-EOS.freeze
```
Commands
--------

help                                 - get this helpful message
wfh [today|tomorrow|weekday|dd/mm]   - log when you are working from home
pto from dd/mm to dd/mm              - log your personal time off
summary [wfh|pto|@user|month]        - shows summary for next 10 calendar days for type or user
entries                              - list your entries and allows you to delete them

```
  EOS
  def self.call(client, data, _match)
    client.say(channel: data.channel, text: HELP, as_user: false)
    logger.info "HELP: #{client.owner}, user=#{data.user}"
  end
end
