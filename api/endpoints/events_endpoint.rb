require "json"

module Api
  module Endpoints
    class EventsEndpoint < Grape::API
      format :json

      namespace :events do
        post "/" do
          case params[:type]
          when "url_verification" then
            params[:challenge]
          when "event_callback" then
            event = params[:event]
            if event[:type] == "app_mention"
              text = event[:text]
              match = text.scan(COMMANDS_REGEXP)
              if match.first == "summary"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Summary.call(nil, data, {expression: event[:text].partition("summary").last})
              end
            else
              error!("Event #{params[:type]} is not supported.", 404)
            end
          else
            error!("Event #{params[:type]} is not supported.", 404)
          end
        end
      end
    end

    class DataObject
      attr_accessor :team
      attr_accessor :user
      attr_accessor :channel
    end
  end
end
