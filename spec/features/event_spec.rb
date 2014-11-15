require 'rails_helper'

feature "Events" do
  def login!(user = nil)
    user ||= Fabricate(:user)
    visit new_user_session_path

    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Log in'
  end

  scenario "User visits the welcome page" do
    login!
    visit '/'
    expect(page).to have_text('Palantir')
  end
end
