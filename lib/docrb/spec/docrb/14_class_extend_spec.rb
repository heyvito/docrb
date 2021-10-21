# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "extracts extended classes" do
    parser = described_class.new(fixture_path("14_class_extend.rb"))
    parser.parse
    expect(parser.classes.first[:extend]).to eq([
                                                  { name: :ExtendsA, class_path: [:Docrb] },
                                                  { name: :ExtendsB, class_path: [:Docrb] },
                                                  { name: :ExtendsC, class_path: [:Docrb] },
                                                  { name: :ExtendsD, class_path: [:Docrb] }
                                                ])
  end
end
