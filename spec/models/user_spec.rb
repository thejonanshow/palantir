require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { Fabricate(:user) }

  context "#ensure_authentication_token" do
    it "generates a unique authentication token when a user is saved" do
      user2 = Fabricate.build(:user)
      allow(Devise).to receive(:friendly_token).exactly(2).times.and_return(
        user.authentication_token, 'unique'
      )

      user2.save
      expect(user2.authentication_token).to_not eql(user.authentication_token)
    end
  end

  context "#generate_authentication_token" do
    it "keeps generating tokens until it generates a unique one" do
      expect(Devise).to receive(:friendly_token).exactly(3).times.and_return(
        user.authentication_token, user.authentication_token, 'unique'
      )
      user.generate_authentication_token
    end
  end
end
