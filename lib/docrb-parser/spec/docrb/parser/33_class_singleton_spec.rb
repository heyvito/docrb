# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(33).nodes.named(:Calculator).first! }

  it "parses methods in singleton class" do
    expect(subject).to have_kind(:class) & be_named(:Calculator)
    expect(subject.instance_methods).to be_empty
    expect(subject.class_methods).not_to be_empty
    expect(subject.class_methods.length).to eq 1
    expect(subject.class_methods.first!).to be_named(:sum)
  end
end
