module Palantir
  class API < Grape::API
    version 'v1', using: :header, vendor: 'palantir'
    prefix :api

    helpers do
      def warden
        env['warden']
      end

      def authenticated?
        return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end

      def current_user
        warden.user || @user
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless authenticated?
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
        image = Image.order(:created_at).last
        image.url if image
      end
    end
  end
end
