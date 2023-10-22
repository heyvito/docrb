# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(30).nodes.named(:Calculator).first! }

  it "parses a simple class" do
    expect(subject).to have_kind(:class) & be_named(:Calculator)
    expect(subject.inherits).not_to be_nil
    expect(subject.inherits.path).to eq [:Object]
    expect(subject.extends).to be_empty
    expect(subject.includes).to be_empty
    expect(subject.class_attributes).to be_empty
    expect(subject.instance_attributes).to be_empty
    expect(subject.classes).to be_empty
    expect(subject.modules).to be_empty
  end

  it "parses defined methods" do
    expect(subject.class_methods).to be_empty
    expect(subject.instance_methods).not_to be_empty
    expect(subject.instance_methods.length).to eq 1
    expect(subject.instance_methods.first!).to be_named(:sum)
  end
end
