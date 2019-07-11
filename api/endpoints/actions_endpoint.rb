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
          message_ts = payload["message_ts"]

          if payload["actions"][0]["name"] == "wfh_confirm"
            date = Date.parse(payload["actions"][0]["value"])
            date_is_today = (Date.today == date)
            if Leave.where(team_id: team_id,
              user_id: user_id,
              leave_type: "wfh",
              start_date: date,
              end_date: date).any?

              {
                "ok": true,
                "channel": channel_id,
                "ts": message_ts,
                "text": "Well, it seems I have already written it down!",
                "as_user": true
              }
            else
              Leave.create(team_id: team_id,
                user_id: user_id,
                leave_type: "wfh",
                start_date: date,
                end_date: date)
              {
                "ok": true,
                "channel": channel_id,
                "ts": message_ts,
                "text": "Gotcha! I've written it down.",
                "as_user": true
              }
            end
          else
            {
              "ok": true,
              "channel": channel_id,
              "ts": message_ts,
              "text": "Second thoughts? No problem, let me know if anything changes.",
              "as_user": true
            }
          end
        end
      end
    end
  end
end
