# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "parses class methods" do
    parser = described_class.new(fixture_path("09_class_method.rb"))
    parser.parse
    expect(parser.classes).not_to be_empty
    expect(parser.modules).to be_empty
    expect(parser.methods).to be_empty
    expect(parser.classes.length).to eq 1

    class_meta = parser.classes.first
    expect(class_meta[:type]).to eq :class
    expect(class_meta[:name]).to eq :Calculator

    expect(class_meta[:start_at]).to eq 1
    expect(class_meta[:end_at]).to eq 5
    expect(class_meta[:doc]).to be_nil

    method_meta = class_meta[:methods].first
    expect(method_meta).to eq({
                                type: :defs,
                                visibility: :public,
                                target: :self,
                                class_path: [],
                                name: :sum,
                                args: [
                                  { type: :arg, name: :a },
                                  { type: :arg, name: :b }
                                ],
                                start_at: 2,
                                end_at: 4,
                                doc: nil
                              })
  end
end
