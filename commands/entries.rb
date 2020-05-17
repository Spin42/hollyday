class Entries < SlackRubyBot::Commands::Base
  command "entries", "Entries", "ENTRIES"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    entries = Entry.where(
      team_id: data.team,
      user_id: data.user).where(
      "(start_date >= ? OR end_date >= ?)", Date.today, Date.today)
      .order(:start_date)

    if entries.any?
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Here are your future entries:",
        attachments: self.entries_attachments(entries))
    else
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Looks like there is nothing planned you...")
    end
  end

  private

  def self.entries_attachments entries
    entries.inject([]) do |attachments, entry|
      attachments << {
        "fallback": "#{MessageUtils::EMOJIS[:"#{entry.entry_type}"]} #{entry.entry_type}",
        "color": "#cccccc",
        "title": "#{MessageUtils::EMOJIS[:"#{entry.entry_type}"]} #{entry.entry_type}",
        "callback_id": "entries_management",
        "text": self.text(entry.start_date, entry.end_date, entry.am, entry.pm, entry.entry_type),
        "actions": [
            {
              "name": "entry_delete",
              "text": "Delete",
              "type": "button",
              "style": "danger",
              "value": entry.to_json
            }
        ]
      }
      attachments
    end
  end

  def self.text start_date, end_date, am, pm, type
    if !(am && pm)
      am_pm_suffix = "in the morning" if am && !pm
      am_pm_suffix = "in the afternoon" if !am && pm
    else
      am_pm_suffix = ""
    end

    if start_date == end_date
      "On #{start_date.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}"
    elsif type == "afk"
      "On #{start_date.strftime(DateUtils::LONG_FORMAT)} from #{start_date.strftime(DateUtils::TIME)} to #{end_date.strftime(DateUtils::TIME)}"
    else
      "From #{start_date.strftime(DateUtils::LONG_FORMAT)} to #{end_date.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}"
    end
  end
end
