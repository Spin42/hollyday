require "awesome_print"

class Wfh < SlackRubyBot::Commands::Base
  command "wfh"
  match(/wfh$*(?<expression>.*)$/)

  def self.call(client, data, _match)
    wfh_day = _match[:expression].strip.split(" ")[0].try(:gsub,",","")
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)
    case wfh_day
    when "summary"
      wfhs = Leave.where(
        team_id: data.team,
        start_date: Date.today..(Date.today+5.days))

      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Here's what's happening during the next days:",
        attachments: self.summary_attachments(wfhs),
        as_user: true)
    when "today"
      webclient.chat_postEphemeral(
        user: data.user,
        channel: data.channel,
        text: "You're working from home today",
        attachments: self.attachments(Date.today),
        as_user: true)
    when "tomorrow"
      webclient.chat_postEphemeral(
        user: data.user,
        channel: data.channel,
        text: "You're working from home tomorrow",
        attachments: self.attachments(Date.today+1.day),
        as_user: true)
    else
      begin
        day_of_the_week = Date.parse(weekday_name).cwday
      rescue Exception => e
        webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: ":thinking_face: Please use today, tomorrow, or any day of the week...",
          as_user: true)
      else
        closest_day = self.closest_day(day_of_the_week)
        webclient.chat_postEphemeral(
          user: data.user,
          channel: data.channel,
          text: "You're working from home on #{closest_day.strftime('%A %B %d')}",
          attachments: self.attachments(closest_day), as_user: true)
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

  def self.summary_attachments wfhs
    attachments = []
    (Date.today..(Date.today+5.days)).each do |date|
      relevant_wfhs = wfhs.select{|wfh| wfh.start_date == date}
      user_ids = relevant_wfhs.map{|wfh| "<@#{wfh.user_id}>"}
      if user_ids.any?
        attachments << {
          "fallback": "List of team members wfh on #{date.strftime("%A %B %d")}",
          "color": "#cccccc",
          "title": ":house_with_garden: #{date.strftime("%A %B %d")}",
          "text": user_ids.join(" ")
        }
      end
    end
    return attachments
  end
end
