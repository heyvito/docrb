# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(32).nodes.named(:Calculator).first! }

  it "parses class methods" do
    expect(subject).to have_kind(:class) & be_named(:Calculator)
    expect(subject.instance_methods).to be_empty
    expect(subject.class_methods).not_to be_empty
    expect(subject.class_methods.length).to eq 1
    expect(subject.class_methods.first!).to be_named(:sum)
  end
end
