class Summary < SlackRubyBot::Commands::Base
  command "summary", "Summary", "SUMMARY"

  def self.call(client, data, _match)
    team             = Team.where(team_id: data.team).first
    webclient        = Slack::Web::Client.new(token: team.token)
    date_range_start = DateTime.now.beginning_of_day
    date_range_end   = DateTime.now.end_of_day+10.days
    matches          = []
    query_parameters = {}

    matches = []
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
          parsed_date = DateTime.parse(match[2])
          if parsed_date < DateTime.now.beginning_of_month
            parsed_date += 1.year
          end

          date_range_start = parsed_date.beginning_of_month
          date_range_end   = parsed_date.end_of_month
        end
        if !match[3].nil?
          date_range_start = DateUtils.interpolate_date_from_string(match[3]).beginning_of_day
          date_range_end   = date_range_start.end_of_day
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
        attachments: self.summary_attachments(entries, date_range_start.to_date..date_range_end.to_date))
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
      relevant_entries = entries.select{|entry| entry.start_date.to_date <= date && entry.end_date.to_date >= date}
      users = relevant_entries.map{|entry| ["<@#{entry.user_id}>", entry.entry_type, entry]}

      if users.any? && !date.on_weekend?
        attachments << {
          "fallback": "List of team members having an entry on #{date.strftime(DateUtils::LONG_FORMAT)}",
          "color": "#cccccc",
          "title": date.strftime(DateUtils::LONG_FORMAT),
          "text": users.map{|user| self.display_text_for_user(user)}.join(" ")
        }
      end
    end
    return attachments
  end

  def self.display_text_for_user user
    if user[1] == "afk"
      "#{MessageUtils.emoji_for(user[1])} #{user[2].start_date.in_time_zone("Europe/Brussels").strftime(DateUtils::TIME)} - #{user[2].end_date.in_time_zone("Europe/Brussels").strftime(DateUtils::TIME)} #{user[0]}"
    else
      "#{MessageUtils.emoji_for(user[1])} #{MessageUtils.am_pm_helper(user[2])} #{user[0]}"
    end
  end
end
