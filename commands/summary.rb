class Summary < SlackRubyBot::Commands::Base
  command "summary"

  def self.call(client, data, _match)
    team       = Team.where(team_id: data.team).first
    webclient  = Slack::Web::Client.new(token: team.token)
    date_range = Date.today..(Date.today+10.days)
    matches    = []

    if _match[:expression]
      matches = _match[:expression].scan(Regexp::ENTRY_TYPE_AND_MONTHS)
    end
    query_parameters = {}

    if matches.any?
      matches.each do |match|
        if ["pto", "wfh"].include?(match[0])
          query_parameters[:entry_type] = match[0]
        end
        if !match[1].nil?
          query_parameters[:user_id] = match[1]
        end
        if !match[2].nil?
          date_range = Date.parse(match[2])..(Date.parse(match[2])+1.month)
        end
      end

      query_parameters[:start_date] = date_range
    end

    query_parameters.merge({team_id: data.team})
    entries = Entry.where(query_parameters).order(:start_date)

    if entries.any?
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Here's what's happening:",
        attachments: self.summary_attachments(entries, date_range))
    else
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Looks like there is nothing planned for the next few days...")
    end
  end

  private

  def self.summary_attachments entries, range
    attachments = []
    (range).each do |date|
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
