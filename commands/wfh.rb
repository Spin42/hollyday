class Wfh < SlackRubyBot::Commands::Base
  command "wfh"
  command "WFH"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    begin
      wfh_day = _match[:expression].scan(Regexp::DAYS_AND_DATES)[0][0]
    rescue Exception => e
      self.post_ErrorMessage(
        webclient, data.user, data.channel,
        ":thinking_face: Please use today, tomorrow, or any day of the week..."
      )
      return
    end

    case wfh_day
    when "today"
      webclient.chat_postEphemeral(
        user: data.user,
        channel: data.channel,
        text: "You're working from home today",
        attachments: self.attachments(Date.today))
    when "tomorrow"
      webclient.chat_postEphemeral(
        user: data.user,
        channel: data.channel,
        text: "You're working from home tomorrow",
        attachments: self.attachments(Date.today+1.day))
    else
      begin
        if !(wfh_day =~ Regexp::DATES).nil?
          day = Date::strptime(wfh_day, DateUtils::SHORT_FORMAT)
        else
          day = Date.parse(wfh_day)
        end
      rescue Exception => e
        self.post_ErrorMessage(
          webclient, data.user, data.channel,
          ":thinking_face: Please use today, tomorrow, or any day of the week... #{e.message}"
        )
      else
        if day <= Date.today
          day = DateUtils.closest_day(day.cwday)
        end

        webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're working from home on #{day.strftime(DateUtils::LONG_FORMAT)}",
          attachments: self.attachments(day))
        end
    end
  end

  private
  def self.attachments date
    return [
      {
        "callback_id": "wfh_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "wfh_confirm",
            "text": "Confirm",
            "type": "button",
            "value": date.to_s,
            "style": "primary"
          },
			    {
					  "name": "wfh_discard",
					  "text": "Discard",
					  "type": "button",
					  "style": "danger"
				  }
			  ]
	    }
	  ]
  end

  def self.post_ErrorMessage(webclient, user, channel, message)
    webclient.chat_postEphemeral(
      user: user,
      channel: channel,
      text: message)
  end
end
