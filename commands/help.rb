class Help < SlackRubyBot::Commands::Base
  HELP = <<-EOS.freeze
```
Commands
--------

help                           - get this helpful message
wfh [today|tomorrow|monday...] - log when you are working from home
wfh summary                    - shows wfh notices for next days

```
  EOS
  def self.call(client, data, _match)
    client.say(channel: data.channel, text: HELP)
    logger.info "HELP: #{client.owner}, user=#{data.user}"
  end
end
