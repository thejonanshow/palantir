class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.all
    @images = Image.where(deleted: false).order(:created_at => :desc).limit(100)
  end
end
