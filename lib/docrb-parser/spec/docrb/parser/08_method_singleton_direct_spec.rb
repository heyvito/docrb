# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  it "parses methods with external receiver" do
    context = parse_fixture(8)
    expect(context.nodes.length).to eq 1
    method = context.nodes.by_kind(:method).first
    expect(method).to be_class
    expect(method.name).to eq :foo
    expect(method.parameters.length).to eq 2

    expect(method.parameters[0]).to be_positional & be_named(:a)
    expect(method.parameters[1]).to be_positional & be_named(:b)
    expect(method).to be_external
    expect(method.external_receiver).not_to be_nil

    expect(method.location.line_start).to eq 1
    expect(method.location.line_end).to eq 3
  end
end
