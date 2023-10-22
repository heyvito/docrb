# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(31).nodes.named(:Calculator).first! }

  it "identifies a constant path inheritance" do
    expect(subject).to have_kind(:class) & be_named(:Calculator)
    expect(subject.inherits).not_to be_nil
    expect(subject.inherits.path).to eq %i[root! Foo Bar Object]
  end
end
