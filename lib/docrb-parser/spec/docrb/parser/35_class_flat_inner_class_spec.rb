# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(35).nodes.first }

  it "defines a path_segment for flat class paths" do
    expect(subject).to have_kind :class
    expect(subject.path_segments).to eq [:Docrb, :App]
  end
end
