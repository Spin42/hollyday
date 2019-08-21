require "json"

module Api
  module Endpoints
    class ActionsEndpoint < Grape::API
      format :json
      desc 'Respond to actions'

      namespace :actions do
        post do
          payload = JSON.parse(params[:payload])
          team_id    = payload["team"]["id"]
          user_id    = payload["user"]["id"]
          channel_id = payload["channel"]["id"]

          if payload["actions"][0]["name"] == "wfh_confirm"
            date = Date.parse(payload["actions"][0]["value"])
            date_is_today = (Date.today == date)
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "wfh", date, date)
          elsif payload["actions"][0]["name"] == "pto_confirm"
            dates = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "pto", dates[0], dates[1])
          else
            status 200
            {
              text: ":sweat_smile: Second thoughts? No problem, let me know if anything changes."
            }
          end
        end
      end

      private
      def self.process_entry team_id, user_id, entry_type, start_date, end_date
        existing_entries = Entry.where(team_id: team_id,
          user_id: user_id,
          entry_type: entry_type,
          start_date: start_date,
          end_date: end_date)

        if existing_entries.any?
          {
            text: ":spiral_calendar_pad: Well, it seems I have already written it down!"
          }
        else
          Entry.create(team_id: team_id,
            user_id: user_id,
            entry_type: entry_type,
            start_date: start_date,
            end_date: end_date)
          {
            text: ":white_check_mark: Gotcha! I've written it down."
          }
        end
      end
    end
  end
end
