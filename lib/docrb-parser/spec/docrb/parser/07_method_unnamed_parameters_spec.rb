# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  it "parses unnamed parameters" do
    context = parse_fixture(7)
    expect(context.nodes.length).to eq 1
    method = context.nodes.by_kind(:method).first
    expect(method).to be_instance
    expect(method.name).to eq :foo
    expect(method.parameters.length).to eq 8

    expect(method.parameters[0]).to be_positional & be_named(:a)
    expect(method.parameters[1]).to be_positional & be_optional & be_named(:b) & have_value
    expect(method.parameters[2]).to be_positional & be_named(:c)
    expect(method.parameters[3]).to be_positional & be_rest & be_named(:*)
    expect(method.parameters[4]).to be_keyword & be_named(:e)
    expect(method.parameters[5]).to be_keyword & be_optional & be_named(:f) & have_value
    expect(method.parameters[6]).to be_keyword & be_rest & be_named(:**)
    expect(method.parameters[7]).to be_block & be_named(:&)

    expect(method.location.line_start).to eq 1
    expect(method.location.line_end).to eq 2
  end
end
