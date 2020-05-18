class Afk < SlackRubyBot::Commands::Base
  command "afk", "AFK", "Afk"

  def self.call(client, data, _match)
    team      = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    matches = []
    if _match[:expression]
      matches = _match[:expression].downcase.scan(Regexp::DAYS_AND_TIMES)
    end

    if matches.any?
      begin
        times = DateUtils.extract_date_and_times_from_matches(matches)
      rescue StandardError => e
      end
    end

    times ||= []

    AfkMessage.render(
      webclient: webclient,
      user: data.user,
      channel: data.channel,
      times: times
    )
  end
end
