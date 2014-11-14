class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.all
    @images = Image.all
  end
end
