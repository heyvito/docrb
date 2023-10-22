# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(9).tap(&:attach_sources!).nodes.named(:Foo).first!.instance_methods }

  it "parses simple send" do
    method = subject.named(:foo).first!
    expect(method).to be_named(:foo)
    expect(method.parameters.length).to eq 1
    expect(method.parameters.first!).to be_positional & be_optional & be_named(:something) & have_value
    expect(method.parameters.first!.value.source).to eq "bar"
  end

  it "parses class send" do
    method = subject.named(:bar).first!
    expect(method).to be_named(:bar)
    expect(method.parameters.length).to eq 1
    expect(method.parameters.first!).to be_positional & be_optional & be_named(:value) & have_value
    expect(method.parameters.first!.value.source).to eq "SomeClass.boom"
  end

  it "parses send on constant path" do
    method = subject.named(:baz).first!
    expect(method).to be_named(:baz)
    expect(method.parameters.first!).to be_positional & be_optional & be_named(:arg) & have_value
    expect(method.parameters.first!.value.source).to eq "SomeModule::SomeClass.beep"
  end
end
