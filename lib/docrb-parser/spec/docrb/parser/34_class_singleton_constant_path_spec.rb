# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(34) }

  it "creates a deferred class representation for unknown classes" do
    s = subject.nodes.first
    expect(s).to have_kind :deferred_singleton_class
    expect(s.target).to eq [:String]
    expect(s.instance_methods.first).to be_named(:sum)
  end
end
