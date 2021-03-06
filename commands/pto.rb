class Pto < SlackRubyBot::Commands::Base
  command "pto", "PTO", "Pto"

  def self.call(client, data, _match)
    team      = Team.where(team_id: data.team).first
    webclient = Slack::Web::Client.new(token: team.token)

    matches = []
    am_pm_matches = []
    recurrent_match = []
    if _match[:expression]
      matches = _match[:expression].downcase.scan(Regexp::DAYS_AND_DATES)
      am_pm_matches = _match[:expression].downcase.scan(Regexp::AM_PM)
      recurrent_match = _match[:expression].downcase.scan(Regexp::RECURRENT)
    end

    dates = []
    if matches.any?
      matches.each do |match|
        dates << DateUtils.extract_date_from_match(match)
      end
    end

    am = true
    pm = true

    if am_pm_matches.any?
      am_pm_matches.each do |match|
        if ["morning","am"].include? match.first
          am = true
          pm = false
        elsif ["afternoon","pm"].include? match.first
          am = false
          pm = true
        end
      end
    end

    PtoMessage.render(
      webclient: webclient,
      user: data.user,
      channel: data.channel,
      dates: dates,
      am: am,
      pm: pm,
      recurring: recurrent_match.any?
    )
  end
end
