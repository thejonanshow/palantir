class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_to_root if User.all.any?

  def redirect_to_root
    redirect_to :root unless current_user
  end

  def new
    super
  end

  def create
    super
  end
end
