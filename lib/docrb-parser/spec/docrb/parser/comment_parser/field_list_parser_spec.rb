# frozen_string_literal: true

RSpec.describe Docrb::Parser::CommentParser do
  it "parses a single line" do
    result = described_class.parse("# field - Here goes docs")
    expect(result).to eq({
      meta: {},
      value: [
        {
          type: :fields,
          value: {
            "field" => {
              type: :block,
              value: [
                { type: :span, value: "Here goes docs" }
              ]
            }
          }
        }
      ]
    })
  end

  it "parses lines with continuations" do
    result = described_class.parse(<<~DOC)
      # field - Here goes docs
      #         that spans multiple lines
    DOC
    expect(result).to eq({
      meta: {},
      value: [
        {
          type: :fields,
          value: {
            "field" => {
              type: :block,
              value: [
                { type: :span, value: "Here goes docs that spans multiple lines" }
              ]
            }
          }
        }
      ]
    })
  end

  it "parses multiple fields" do
    result = described_class.parse(<<~DOC)
      # field_a - Field A docs
      # field_b - Field B docs
    DOC
    expect(result).to eq({
      meta: {},
      value: [
        {
          type: :fields,
          value: {
            "field_a" => { type: :block, value: [{ type: :span, value: "Field A docs" }] },
            "field_b" => { type: :block, value: [{ type: :span, value: "Field B docs" }] }
          }
        }
      ]
    })
  end

  it "parses multiple continuations" do
    result = described_class.parse(<<~DOC)
      # field - Here goes docs
      #         that spans multiple lines
      #         and multiple lines
    DOC
    expect(result).to eq({
      meta: {},
      value: [
        {
          type: :fields,
          value: {
            "field" => {
              type: :block,
              value: [
                {
                  type: :span,
                  value: "Here goes docs that spans multiple lines\n and multiple lines"
                }
              ]
            }
          }
        }
      ]
    })
  end

  it "parses multiple lines" do
    input = <<~DOC
      # fields  - A hash containing metadata to be included in logs emitted by this
      #           instance.
      # level   - The level filter for the instance. Valid values are :error, :fatal,
      #           :info, :warn, and :debug
      # format: - The format to output logs. Supports :text and :json.
    DOC

    result = described_class.parse(input)
    expect(result).to eq({
      meta: {},
      value: [
        {
          type: :fields,
          value: {
            "fields" => {
              type: :block,
              value: [
                {
                  type: :span,
                  value: "A hash containing metadata to be included in logs emitted by this instance.\n"
                }
              ]
            },
            "format:" => {
              type: :block,
              value: [
                { type: :span, value: "The format to output logs. Supports " },
                { type: :symbol, value: ":text" },
                { type: :span, value: " and " },
                { type: :symbol, value: ":json" },
                { type: :span, value: "." }
              ]
            },
            "level" => {
              type: :block,
              value: [
                { type: :span, value: "The level filter for the instance. Valid values are " },
                { type: :symbol, value: ":error" },
                { type: :span, value: ", " },
                { type: :symbol, value: ":fatal" },
                { type: :span, value: ", " },
                { type: :symbol, value: ":info" },
                { type: :span, value: ", " },
                { type: :symbol, value: ":warn" },
                { type: :span, value: ", and " },
                { type: :symbol, value: ":debug" },
                { type: :span, value: "\n" }
              ]
            }
          }
        }
      ]
    })
  end
end
