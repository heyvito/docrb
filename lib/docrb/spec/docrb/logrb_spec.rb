# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "parses real code" do
    parser = described_class.new(fixture_path("logrb.rb"))
    parser.parse
  end
end
