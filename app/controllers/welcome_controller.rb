class WelcomeController < ApplicationController
  def index
    @events = Event.all
    @images = Image.all
  end
end
