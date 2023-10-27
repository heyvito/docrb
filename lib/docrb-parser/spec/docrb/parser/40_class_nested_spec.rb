# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(40).nodes.first.classes.first }

  it "handles nested classes" do
    expect(subject).to be_named(:Bar) & have_kind(:class)
  end
end
