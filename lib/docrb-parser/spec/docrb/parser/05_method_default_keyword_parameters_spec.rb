# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  it "parses optional keyword arguments" do
    context = parse_fixture(5)
    expect(context.nodes.length).to eq 1
    method = context.nodes.by_kind(:method).first
    expect(method).to be_instance
    expect(method.name).to eq :sum
    expect(method.parameters.length).to eq 2

    expect(method.parameters[0]).to be_keyword & be_optional & be_named(:a) & have_value
    expect(method.parameters[1]).to be_keyword & be_optional & be_named(:b) & have_value

    expect(method.location.line_start).to eq 7
    expect(method.location.line_end).to eq 9
  end
end
