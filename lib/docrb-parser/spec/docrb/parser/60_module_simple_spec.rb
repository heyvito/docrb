# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(60).nodes.first }

  it "handles simple modules" do
    expect(subject).to be_named :App
    expect(subject.classes).not_to be_empty
  end
end
