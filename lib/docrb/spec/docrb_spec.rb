# frozen_string_literal: true

RSpec.describe Docrb do
  it "has a version number" do
    expect(Docrb::VERSION).not_to be nil
  end

  it "parses real code" do
    expect { Docrb.parse(fixture_path("errors.rb")) }.to_not raise_error
  end
end
