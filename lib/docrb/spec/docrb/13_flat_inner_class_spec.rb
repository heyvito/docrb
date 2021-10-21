# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "handles 'flat' inner class" do
    parser = described_class.new(fixture_path("13_flat_inner_class.rb"))
    parser.parse
    expect(parser.classes).not_to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    expect(parser.classes.length).to eq 1
  end
end
