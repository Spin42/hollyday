class Pto < SlackRubyBot::Commands::Base
  command "pto"
  command "PTO"

  ENTRY_TYPE = "pto"

  def self.call(client, data, _match)
    team      = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    begin
      dates = _match[:expression].scan(Regexp::DATES)
      from  = Date::strptime(dates[0][0], DateUtils::SHORT_FORMAT)
      to    = Date::strptime(dates[1][0], DateUtils::SHORT_FORMAT) if dates.size > 1
    rescue Exception => e
      self.fail webclient, data.user, data.channel
      return
    end

    if !from.nil? && !to.nil? && from < to
      webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're taking some personal time off from #{from.strftime(DateUtils::LONG_FORMAT)} to #{to.strftime(DateUtils::LONG_FORMAT)} #{MessageUtils.emoji_for(ENTRY_TYPE)}",
          attachments: self.attachments([from, to]))
    elsif !from.nil? && to.nil?
      webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're taking some personal time on #{from.strftime(DateUtils::LONG_FORMAT)} #{MessageUtils.emoji_for(ENTRY_TYPE)}",
          attachments: self.attachments([from, from]))
    else
      self.fail webclient, data.user, data.channel
    end
  end

  private

  def self.fail webclient, user, channel
    webclient.chat_postEphemeral(
      user: user,
      channel: channel,
      text: ":thinking_face: Please ask me for 'help' if you don't know how to book pto..."
    )
  end

  def self.attachments dates
    return [
      {
        "callback_id": "pto_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "pto_confirm",
            "text": "Confirm",
            "type": "button",
            "value": dates.to_json,
            "style": "primary"
          },
			    {
					  "name": "pto_discard",
					  "text": "Discard",
					  "type": "button",
					  "style": "danger"
				  }
			  ]
	    }
	  ]
  end
end
