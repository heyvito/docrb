# frozen_string_literal: true

RSpec.describe Docrb do
  it "has a version number" do
    expect(Docrb::VERSION).not_to be nil
  end

  it "parses real code" do
    result = Docrb.parse(fixture_path("errors.rb"))
    byebug
  end
end
