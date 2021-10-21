# frozen_string_literal: true

RSpec.describe Docrb::RubyParser do
  it "extracts accessors" do
    parser = described_class.new(fixture_path("16_attr_accessor.rb"))
    parser.parse
    cls = parser.classes.first
    expect(cls[:attr_reader]).to eq([{
                                      docs: nil,
                                      name: :status,
                                      reader_visibility: :public,
                                      writer_visibility: :public
                                    }])
    expect(cls[:attr_writer]).to eq([{
                                      docs: nil,
                                      name: :input,
                                      reader_visibility: :public,
                                      writer_visibility: :public
                                    }])
    expect(cls[:attr_accessor]).to eq([
                                        { docs: nil, name: :foo, reader_visibility: :public,
                                          writer_visibility: :public },
                                        { docs: nil, name: :bar, reader_visibility: :public,
                                          writer_visibility: :public },
                                        { docs: nil, name: :baz, reader_visibility: :public,
                                          writer_visibility: :public }
                                      ])
  end
end
