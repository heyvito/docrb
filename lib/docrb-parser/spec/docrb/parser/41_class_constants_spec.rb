# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { parse_fixture(41).nodes.first }

  it "handles nested classes" do
    expect(subject.constants.named(:CONST_A).first).not_to be_nil
    expect(subject.constants.named(:CONST_B).first).not_to be_nil
    expect(subject.constants.named(:CONST_C).first).not_to be_nil
  end
end
