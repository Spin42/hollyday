class Summary < SlackRubyBot::Commands::Base
  command "summary"

  def self.call(client, data, _match)
    team             = Team.where(team_id: data.team).first
    webclient        = Slack::Web::Client.new(token: team.token)
    date_range_start = Date.today
    date_range_end   = Date.today+10.days
    matches          = []
    query_parameters = {}

    if _match[:expression]
      matches = _match[:expression].scan(Regexp::ENTRY_TYPE_DAYS_AND_MONTHS)
    end

    if matches.any?
      matches.each do |match|
        if Entry::AVAILABLE_TYPES.include?(match[0])
          query_parameters[:entry_type] = match[0]
        end
        if !match[1].nil?
          query_parameters[:user_id] = match[1]
        end
        if !match[2].nil?
          parsed_date = Date.parse(match[2])
          if parsed_date < Date.today
            parsed_date += 1.year
          end

          date_range_start = parsed_date
          date_range_end   = parsed_date.end_of_month
        end
        if !match[3].nil?
          date_range_start = DateUtils.interpolate_date_from_string(match[3])
          date_range_end   = date_range_start
        end
      end
    end

    query_parameters.merge({team_id: data.team})
    entries = Entry.where(query_parameters).
      where("start_date <= ? AND end_date >= ?", date_range_end, date_range_start).
      order(:start_date)

    if entries.any?
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Here's what's happening:",
        attachments: self.summary_attachments(entries, date_range_start..date_range_end))
    else
      webclient.chat_postMessage(
        user: data.user,
        channel: data.channel,
        text: "Looks like there is nothing planned...")
    end
  end

  private

  def self.summary_attachments entries, range
    attachments = []
    (range).each do |date|
      relevant_entries = entries.select{|entry| entry.start_date <= date && entry.end_date >= date}
      users = relevant_entries.map{|entry| ["<@#{entry.user_id}>", entry.entry_type]}

      if users.any? && !date.on_weekend?
        attachments << {
          "fallback": "List of team members having an entry on #{date.strftime(DateUtils::LONG_FORMAT)}",
          "color": "#cccccc",
          "title": date.strftime(DateUtils::LONG_FORMAT),
          "text": users.map{|user| "#{MessageUtils.emoji_for(user[1])} #{user[0]}"}.join(" ")
        }
      end
    end
    return attachments
  end
end
