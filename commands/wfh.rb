require "awesome_print"

class Wfh < SlackRubyBot::Commands::Base
  command "wfh"
  command "WFH"
  match(/wfh$*(?<expression>.*)$/)
  match(/WFH$*(?<expression>.*)$/)

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    begin
      wfh_day = _match[:expression].strip.split(" ")[0].try(:gsub,",","")
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
        day_of_the_week = Date.parse(wfh_day).cwday
      rescue Exception => e
        self.post_ErrorMessage(
          webclient, data.user, data.channel,
          ":thinking_face: Please use today, tomorrow, or any day of the week..."
        )
      else
        closest_day = self.closest_day(day_of_the_week)
        webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're working from home on #{closest_day.strftime('%A %B %d')}",
          attachments: self.attachments(closest_day))
        end
    end
  end

  private
  def self.closest_day(day_of_the_week, date=Date.today)
    if day_of_the_week > date.cwday
      date + (day_of_the_week - date.cwday)
    else
      date + 7 - (date.cwday - day_of_the_week)
    end
  end

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
      text: message,
      as_user: true)
  end
end
