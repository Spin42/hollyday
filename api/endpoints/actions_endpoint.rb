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
            if Leave.where(team_id: team_id,
              user_id: user_id,
              leave_type: "wfh",
              start_date: date,
              end_date: date).any?
              status 200
              {
                "user": user_id,
                "channel": channel_id,
                "attachments": [],
                "replace_original": true,
                "as_user": true,
                "text": "Well, it seems I have already written it down!"
              }
            else
              Leave.create(team_id: team_id,
                user_id: user_id,
                leave_type: "wfh",
                start_date: date,
                end_date: date)
              status 200
              {
                "user": user_id,
                "channel": channel_id,
                "attachments": [],
                "replace_original": true,
                "as_user": true,
                "text": "Gotcha! I've written it down."
              }
            end
          else
            status 200
            {
              "user": user_id,
              "channel": channel_id,
              "attachments": [],
              "replace_original": true,
              "as_user": true,
              "text": "Second thoughts? No problem, let me know if anything changes."
            }
          end
        end
      end
    end
  end
end
