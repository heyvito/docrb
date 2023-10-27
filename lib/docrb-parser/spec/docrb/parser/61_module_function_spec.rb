# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(61).nodes.first }

  it "handles module functions" do
    expect(subject.class_methods.named(:foo).first!.type).to eq :module_function
    expect(subject.instance_methods.named(:bar).first!.type).to eq :instance
    expect(subject.class_methods.named(:baz).first!.type).to eq :module_function
    expect(subject.instance_methods.named(:instance).first!.type).to eq :instance
    expect(subject.class_methods.named(:fox).first!.type).to eq :module_function
  end
end
