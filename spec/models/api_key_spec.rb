require 'rails_helper'

RSpec.describe ApiKey, :type => :model do
  context "#generate_token" do
    let(:key) { ApiKey.new }

    it "sets the token on the api key" do
      expect(key).to_not be nil
    end

    it "does not set the token if it is already set" do
      key_with_supplied_token = ApiKey.create(token: 'test_token')
      expect(key_with_supplied_token.token).to eql('test_token')
    end

    it "generates a unique token" do
      allow(SecureRandom).to receive(:hex).twice.and_return '12345'
      unique_key = ApiKey.create

      expect(unique_key.token).to eql('12345')
      expect(key.token).to_not eql('12345')
    end
  end
end
