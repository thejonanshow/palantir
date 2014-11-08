module Palantir
  class API < Grape::API
    version 'v1', using: :header, vendor: 'palantir'
    format :json
    prefix :api

    helpers do
      def valid_api_key?
        !ApiKey.where(secret: 'secret').empty?
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless valid_api_key?
      end
    end

    resource :images do
      desc "Create an image."

      post do
        authenticate!
        Image.create!({
          url: params[:url],
          phash: params[:phash]
        })
      end
    end
  end
end
