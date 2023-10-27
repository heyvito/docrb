# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(38).nodes.first }

  it "stores attributes" do
    attr = subject.instance_attributes
    expect(attr.named(:foo).first!.type).to eq :accessor
    expect(attr.named(:bar).first!.type).to eq :accessor
    expect(attr.named(:baz).first!.type).to eq :accessor
    expect(attr.named(:status).first!.type).to eq :reader
    expect(attr.named(:input).first!.type).to eq :writer
    expect(attr.named(:manually_defined).first!.type).to eq :accessor
    expect(attr.named(:explicit_reader).first!.type).to eq :accessor
    expect(attr.named(:explicit_writer).first!.type).to eq :accessor

    attr = subject.class_attributes
    expect(attr.named(:exp_class_accessor).first!.type).to eq :accessor
    expect(attr.named(:test).first!.type).to eq :accessor
  end
end
