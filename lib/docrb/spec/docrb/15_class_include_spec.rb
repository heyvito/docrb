RSpec.describe Docrb::RubyParser do
  it "extracts included classes" do
    parser = described_class.new(fixture_path("15_class_include.rb"))
    parser.parse
    expect(parser.classes.first[:include]).to eq([
      {name: :IncludeA, class_path: [:Docrb]},
      {name: :IncludeB, class_path: [:Docrb]},
    ])
  end
end
