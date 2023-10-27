# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(37).nodes.first }

  it "registers included modules" do
    includes = subject.includes
    expect(includes[0].path).to eq %i[Docrb IncludeA]
    expect(includes[1].path).to eq %i[Docrb IncludeB]
  end
end
