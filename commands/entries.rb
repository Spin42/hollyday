class Entries < SlackRubyBot::Commands::Base
  command "entries"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    entries = Entry.where(
      team_id: data.team,
      user_id: data.user).where(
      "start_date <= ? AND end_date >= ?", Date.today, Date.today)

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
    emojis = {"wfh": ":house_with_garden:", "pto": ":palm_tree:"}
    entries.inject([]) do |attachments, entry|
      attachments << {
        "fallback": "#{emojis[:"#{entry.entry_type}"]} #{entry.entry_type}",
        "color": "#cccccc",
        "title": "#{emojis[:"#{entry.entry_type}"]} #{entry.entry_type}",
        "callback_id": "entries_management",
        "text": "From #{entry.start_date.strftime("%A %B %d")} to #{entry.end_date.strftime("%A %B %d")}",
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
end
