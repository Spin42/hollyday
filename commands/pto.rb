class Off < SlackRubyBot::Commands::Base
  command "pto"
  command "PTO"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    begin
      dates = _match[:expression].scan(/(\d{1,2}\/\d{1,2})/)
      from = Date::strptime(dates[0][0],"%d/%m")
      to   = Date::strptime(dates[1][0],"%d/%m") if dates.size > 1
    rescue Exception => e
      self.post_ErrorMessage(
        webclient, data.user, data.channel,
        ":thinking_face: Please ask me for 'help' if you don't know how to book pto..."
      )
      return
    end

    if !from.nil? && !to.nil? && from < to
      webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're taking some personal time off from #{from.strftime("%d/%m/%Y")} to #{to.strftime("%d/%m/%Y")} :palm_tree:",
          attachments: self.attachments([from, to]))
    elsif !from.nil? && to.nil?
      webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're taking some personal time on #{from.strftime("%d/%m/%Y")} :palm_tree:",
          attachments: self.attachments([from, from]))
    else
      self.post_ErrorMessage(
        webclient, data.user, data.channel,
        ":thinking_face: Please ask me for 'help' if you don't know how to book pto..."
      )
    end
  end

  private

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

  def self.post_ErrorMessage(webclient, user, channel, message)
    webclient.chat_postEphemeral(
      user: user,
      channel: channel,
      text: message)
  end
end
