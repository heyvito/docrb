# frozen_string_literal: true

RSpec.describe Docrb::Parser do
  subject { Docrb::Parser.new.tap { _1.debug = true }.parse(fixture_named("logrb.rb")) }
  it "parses logrb.rb" do
    expect { subject }.not_to raise_error
  end
end
