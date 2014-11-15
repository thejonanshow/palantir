class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.all
    @images = Image.order(:created_at => :desc).limit(100)
  end
end
