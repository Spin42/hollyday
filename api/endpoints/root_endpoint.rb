module Api
  module Endpoints
    class RootEndpoint < Grape::API
      prefix 'api'

      format :json
      formatter :json, Grape::Formatter::Roar

      mount Api::Endpoints::ActionsEndpoint
      mount Api::Endpoints::StatusEndpoint
      mount Api::Endpoints::TeamsEndpoint
    end
  end
end
