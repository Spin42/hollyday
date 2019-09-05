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
            dates = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "wfh", dates[0], dates[1])
          elsif payload["actions"][0]["name"] == "pto_confirm"
            dates = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "pto", dates[0], dates[1])
          elsif payload["actions"][0]["name"] == "entry_delete"
            entry_hash = JSON.parse(payload["actions"][0]["value"])
            entry = Entry.where(id: entry_hash["id"], user_id: entry_hash["user_id"]).first()

            team = Team.where(team_id: team_id).first
            webclient = Slack::Web::Client.new(token: team.token)

            attachments = payload["original_message"]["attachments"]
            deleted_attachment = attachments.find{|attachment| attachment.key?("actions") && JSON.parse(attachment["actions"][0]["value"]) == entry_hash}
            deleted_attachment_index = attachments.index(deleted_attachment)

            replacement_attachment = {
              "id": deleted_attachment["id"],
              "fallback": "Deleted #{MessageUtils::EMOJIS[:"#{entry_hash["entry_type"]}"]} #{entry_hash["entry_type"]}",
              "color": "#ff0000",
              "title": "Deleted #{MessageUtils::EMOJIS[:"#{entry_hash["entry_type"]}"]} #{entry_hash["entry_type"]}",
              "callback_id": "entries_management",
              "text": Api::Endpoints::ActionsEndpoint.text(entry.start_date, entry.end_date)
            }
            attachments[deleted_attachment_index] = replacement_attachment

            entry.destroy if !entry.nil?

            webclient.chat_update(
              channel: channel_id,
              ts: payload["original_message"]["ts"],
              attachments: attachments
            )
            status 204
            ""
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

      def self.text start_date, end_date
        if start_date == end_date
          "On #{start_date.strftime("%A %B %d")}"
        else
          "From #{start_date.strftime("%A %B %d")} to #{end_date.strftime("%A %B %d")}"
        end
      end
    end
  end
end
