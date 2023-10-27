# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  it "parses keyword arguments" do
    context = parse_fixture(3)
    expect(context.nodes.length).to eq 1
    method = context.nodes.by_kind(:method).first
    expect(method).to be_instance
    expect(method.name).to eq :sum
    expect(method.parameters.length).to eq 3

    expect(method.parameters[0]).to be_keyword & be_named(:a)
    expect(method.parameters[1]).to be_keyword & be_named(:b)
    expect(method.parameters[2]).to be_keyword & be_named(:c)

    expect(method.location.line_start).to eq 8
    expect(method.location.line_end).to eq 10
  end
end
