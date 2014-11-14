require 'rails_helper'

RSpec.describe EventsController, :type => :controller do

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET show" do
    it "returns http success" do
      event = Fabricate(:event)
      get :show, :id => event.id
      expect(response).to have_http_status(:success)
    end
  end

end
