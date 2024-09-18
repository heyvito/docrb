RSpec.describe Docrb::Parser do
  subject { Docrb::Parser.new.tap { _1.debug = true }.parse(fixture_named("emrb_edge.rb")) }
  it "parses emrb_edge.rb" do
    expect do
      s = subject
      puts s
    end.not_to raise_error
  end
end
