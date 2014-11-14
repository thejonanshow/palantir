require 'rails_helper'

RSpec.describe NotificationService, :type => :model do
  let(:service) { NotificationService.new }

  context ".client" do
    it "only creates one client" do
      expect(NotificationService.client).to eql(NotificationService.client)
    end
  end

  context "#notify" do
    it "sends a message" do
      message = 'Three Rings for the Elven-kings under the sky'
      expect(service.client).to receive(:update).with(message)
      service.notify(message)
    end
  end
end
