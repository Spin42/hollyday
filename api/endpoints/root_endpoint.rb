module Api
  module Endpoints
    class RootEndpoint < Grape::API
      format :json
      formatter :json, Grape::Formatter::Roar

      mount Api::Endpoints::ActionsEndpoint
    end
  end
end
