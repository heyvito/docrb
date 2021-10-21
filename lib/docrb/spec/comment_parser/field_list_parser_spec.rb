RSpec.describe Docrb::CommentParser::FieldListParser do
  it "parses a single line" do
    parser = described_class.new("field - Here goes docs")
    expect(parser.detect).to eq true
    expect(parser.result).to eq({
      "field" => "Here goes docs"
    })
  end

  it "parses lines with continuations" do
    parser = described_class.new(<<~DOC)
    field - Here goes docs
            that spans multiple lines
    DOC
    expect(parser.detect).to eq true
    expect(parser.result).to eq({
      "field" => "Here goes docs that spans multiple lines",
    })
  end

  it "parses multiple fields" do
    parser = described_class.new(<<~DOC)
    field_a - Field A docs
    field_b - Field B docs
    DOC
    expect(parser.detect).to eq true
    expect(parser.result).to eq({
      "field_a" => "Field A docs",
      "field_b" => "Field B docs",
    })
  end

  it "parses multiple continuations" do
    parser = described_class.new(<<~DOC)
    field - Here goes docs
            that spans multiple lines
            and multiple lines
    DOC
    expect(parser.detect).to eq true
    expect(parser.result).to eq({
      "field" => "Here goes docs that spans multiple lines and multiple lines",
    })
  end

  it "parses multiple lines" do
    input = <<~DOC
      fields  - A hash containing metadata to be included in logs emitted by this
                instance.
      level   - The level filter for the instance. Valid values are :error, :fatal,
                :info, :warn, and :debug
      format: - The format to output logs. Supports :text and :json.
    DOC

    parser = described_class.new(input)
    expect(parser.detect).to eq true
    expect(parser.result).to eq({
      "fields"  => "A hash containing metadata to be included in logs emitted by this instance.",
      "level"   => "The level filter for the instance. Valid values are :error, :fatal, :info, :warn, and :debug",
      "format:" => "The format to output logs. Supports :text and :json."
    })
  end
end
