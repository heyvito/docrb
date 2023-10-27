# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(36).nodes.first }

  it "registers extended modules" do
    extends = subject.extends
    expect(extends[0].path).to eq %i[Docrb ExtendsA]
    expect(extends[1].path).to eq %i[Docrb ExtendsB]
    expect(extends[2].path).to eq %i[Docrb ExtendsC]
    expect(extends[3].path).to eq %i[Docrb ExtendsD]
  end
end
