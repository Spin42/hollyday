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
            value = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "wfh", value[0], value[1], value[2], value[3], value[4])
          elsif payload["actions"][0]["name"] == "pto_confirm"
            value = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "pto", value[0], value[1], value[2], value[3], value[4])
          elsif payload["actions"][0]["name"] == "sick_confirm"
            value = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "sick", value[0], value[1], value[2], value[3], false)
          elsif payload["actions"][0]["name"] == "afk_confirm"
            puts "yoyoyoyoyo"
            value = JSON.parse(payload["actions"][0]["value"])
            status 200
            Api::Endpoints::ActionsEndpoint.process_entry(team_id, user_id, "afk", value[0], value[1], false, false, false)
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
      def self.process_entry team_id, user_id, entry_type, start_date, end_date, am=true, pm=true, recurring=false
        existing_entries = Entry.where(team_id: team_id,
          user_id: user_id,
          entry_type: entry_type,
          start_date: DateTime.parse(start_date),
          end_date: DateTime.parse(end_date),
          am: am,
          pm: pm)

        if existing_entries.any?
          {
            text: ":spiral_calendar_pad: Well, it seems I have already written it down!"
          }
        else
          occurences = recurring ? 12 : 1
          errors = []
          puts occurences.inspect
          occurences.times do |index|
            entry = Entry.create(team_id: team_id,
              user_id: user_id,
              entry_type: entry_type,
              start_date: DateTime.parse(start_date)+(index).weeks,
              end_date: DateTime.parse(end_date)+(index).weeks,
              am: am,
              pm: pm)
            errors << entry.errors if entry.errors.any?
          end

          if errors.any?
            {
              text: ":no_entry_sign: #{entry.errors.full_messages.join(", ")}"
            }
          else
            self.publish_feedback_message_for_entry team_id, user_id, entry_type, start_date, end_date
            {
              text: ":white_check_mark: Gotcha! I've written it down."
            }
          end
        end
      end

      def self.text start_date, end_date
        if start_date == end_date
          "On #{start_date.strftime("%A %B %d")}"
        else
          "From #{start_date.strftime("%A %B %d")} to #{end_date.strftime("%A %B %d")}"
        end
      end

      def self.publish_feedback_message_for_entry team_id, user_id, entry_type, start_date, end_date
        if entry_type == "afk"
          team      = Team.where(team_id: team_id).first
          webclient = Slack::Web::Client.new(token: team.token)
          channels = webclient.channels_list.channels
          afk_channel = channels.detect { |c| c.name == "afk" }
          if afk_channel
            if start_date < DateTime.current.end_of_day && end_date < DateTime.current.end_of_day
              webclient.chat_postMessage(
                as_user: true,
                channel: "#afk",
                text: "<@#{user_id}> is afk from #{DateTime.parse(start_date).strftime(DateUtils::TIME)} to #{DateTime.parse(end_date).strftime(DateUtils::TIME)}"
              )
            else
              webclient.chat_postMessage(
                as_user: true,
                channel: "#afk",
                text: "<@#{user_id}> will be afk on #{DateTime.parse(start_date).strftime(DateUtils::LONG_FORMAT)} from #{DateTime.parse(start_date).strftime(DateUtils::TIME)} to #{DateTime.parse(end_date).strftime(DateUtils::TIME)}"
              )
            end
          end
        end
      end
    end
  end
end
