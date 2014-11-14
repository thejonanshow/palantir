module Palantir
  class API < Grape::API
    version 'v1', using: :header, vendor: 'palantir'
    prefix :api

    helpers do
      def warden
        env['warden']
      end

      def authenticated_with_warden?
        return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end

      def current_user
        warden.user || @user
      end

      def valid_api_key?
        return false unless header_token = headers['Authorization']
        header_token = header_token.split('=').last
        ApiKey.where(token: header_token).present?
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless valid_api_key? || authenticated_with_warden?
      end
    end

    resource :images do
      desc "Create an image."
      post do
        authenticate!
        Image.create!(params['image'])
      end

      desc "Get the latest image URL"
      get :latest do
        authenticate!
        Image.order(:created_at).last.url
      end
    end
  end
end
