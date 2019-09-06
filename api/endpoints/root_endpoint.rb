module Api
  module Endpoints
    class RootEndpoint < Grape::API
      include Api::Helpers::ErrorHelpers
      prefix 'api'

      format :json
      formatter :json, Grape::Formatter::Roar

      mount Api::Endpoints::ActionsEndpoint
      mount Api::Endpoints::StatusEndpoint
      mount Api::Endpoints::TeamsEndpoint
      mount Api::Endpoints::EventsEndpoint
    end
  end
end
