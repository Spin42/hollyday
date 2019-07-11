require "awesome_print"

class Wfh < SlackRubyBot::Commands::Base
  command "wfh"

  def self.call(client, data, _match)
    wfh_day = _match[:expression]
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)
    if wfh_day == "summary"
      wfhs = Leave.where(team_id: data.team, start_date: Date.today..(Date.today+5.days))
      webclient.chat_postMessage(channel: data.channel, text: "Here are the team members wfh during the next 5 days:", attachments: self.summary_attachments(wfhs), as_user: true)
    elsif wfh_day == "today"
      webclient.chat_postMessage(channel: data.channel, text: "You're working from home today", attachments: self.attachments(Date.today), as_user: true)
    elsif wfh_day == "tomorrow"
      webclient.chat_postMessage(channel: data.channel, text: "You're working from home tomorrow", attachments: self.attachments(Date.today+1.day), as_user: true)
    else
      closest_day = self.closest_day(wfh_day)
      webclient.chat_postMessage(channel: data.channel, text: "You're working from home on #{closest_day.strftime('%A %B %d')}", attachments: self.attachments(closest_day), as_user: true)
    end
  end

  private
  def self.closest_day(weekday_name, date=Date.today)
    day_of_the_week = Date.parse(weekday_name).cwday
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

  def self.summary_attachments wfhs
    attachments = []
    (Date.today..(Date.today+5.days)).each do |date|
      relevant_wfhs = wfhs.select{|wfh| wfh.start_date == date}
      user_ids = relevant_wfhs.map{|wfh| "<@#{wfh.user_id}>"}
      if user_ids.any?
        attachments << {
          "fallback": "List of team members wfh on #{date.strftime("%A %B %d")}",
          "color": "#36a64f",
          "title": date.strftime("%A %B %d"),
          "text": user_ids.join(" ")
        }
      end
    end
    return attachments
  end
end
