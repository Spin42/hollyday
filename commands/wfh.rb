class Wfh < SlackRubyBot::Commands::Base
  command "wfh"
  command "WFH"

  def self.call(client, data, _match)
    team = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    if _match[:expression]
      matches = _match[:expression].scan(Regexp::DAYS_AND_DATES)
    end

    dates = []
    if matches.any?
      matches.each do |match|
        dates << DateUtils.extract_date_from_match(match)
      end
    end

    WfhMessage.render(
      webclient: webclient,
      user: data.user,
      channel: data.channel,
      dates: dates
    )
  end
end
