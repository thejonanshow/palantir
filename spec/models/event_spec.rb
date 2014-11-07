require 'rails_helper'

RSpec.describe Event, :type => :model do
  let(:event) { Event.new }

  context "#create" do
    it "sets the event bucket name" do
      timestamp_regex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}-\d{9}/
      expect(event.bucket_name).to match /palantir_event_#{timestamp_regex}/
    end
  end
end
