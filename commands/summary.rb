class Off < SlackRubyBot::Commands::Base
  command "summary"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    entries = Entry.where(
      team_id: data.team,
      start_date: Date.today..(Date.today+10.days))
    webclient.chat_postMessage(
      user: data.user,
      channel: data.channel,
      text: "Here's what's happening during the next days:",
      attachments: self.summary_attachments(entries))

  end

  private

  def self.summary_attachments entries
    attachments = []
    (Date.today..(Date.today+10.days)).each do |date|
      relevant_entries = entries.select{|entry| entry.start_date <= date && entry.end_date >= date}
      users = relevant_entries.map{|entry| ["<@#{entry.user_id}>", entry.entry_type]}
      emojis = {"wfh": ":house_with_garden:", "pto": ":palm_tree:"}

      if users.any?
        attachments << {
          "fallback": "List of team members having an entry on #{date.strftime("%A %B %d")}",
          "color": "#cccccc",
          "title": date.strftime("%A %B %d"),
          "text": users.map{|user| "#{emojis[:"#{user[1]}"]} #{user[0]}"}.join(" ")
        }
      end
    end
    return attachments
  end
end
