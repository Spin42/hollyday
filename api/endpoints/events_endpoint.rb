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
              if match.first == "help"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Help.call(nil, data, {expression: event[:text].partition("help").last})
              end
              if match.first == "wfh"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Wfh.call(nil, data, {expression: event[:text].partition("wfh").last})
              end
              if match.first == "pto"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Pto.call(nil, data, {expression: event[:text].partition("pto").last})
              end
              if match.first == "afk"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Afk.call(nil, data, {expression: event[:text].partition("afk").last})
              end
              if match.first == "entries"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Entries.call(nil, data, {expression: event[:text].partition("entries").last})
              end
              if match.first == "sick"
                data = DataObject.new()
                data.team = event[:team]
                data.channel = event[:channel]
                Sick.call(nil, data, {expression: event[:text].partition("sick").last})
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
