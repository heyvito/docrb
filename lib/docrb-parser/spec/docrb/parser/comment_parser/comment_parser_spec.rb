# frozen_string_literal: true

RSpec.describe Docrb::Parser::CommentParser do
  it "parses class comments" do
    input = <<~DOC
      # Logrb provides a facility for working with logs in text and json formats.
      # All instances share a single mutex to ensure logging consistency.
      # The following attributes are available:
      #
      # fields - A hash containing metadata to be included in logs emitted by this
      #          instance.
      # level  - The level filter for the instance. Valid values are :error, :fatal,
      #          :info, :warn, and :debug
      # format - The format to output logs. Supports :text and :json.
      #
      # Each instance exposes the following methods, which accepts an arbitrary
      # number of key-value pairs to be included in the logged message:
      #
      # #error(msg, error=nil, **fields): Outputs an error entry. When `error` is
      #   present, attempts to obtain backtrace information and also includes it
      #   to the emitted entry.
      #
      # #fatal(msg, **fields): Outputs a fatal entry. Calling fatal causes the
      #   current process to exit with a status 1.
      #
      # #warn(msg, **fields): Outputs a warning entry.
      # #info(msg, **fields): Outputs a informational entry.
      # #debug(msg, **fields): Outputs a debug entry.
      # #dump(msg, data=nil): Outputs a given String or Array of bytes using the
      #   same format as `hexdump -C`.
    DOC

    output = {
      meta: {},
      value: [
        {
          type: :block,
          value: [
            { type: :span, value: "Logrb provides a facility for working with logs in text and json formats.\nAll instances share a single mutex to ensure logging consistency.\nThe following attributes are available:" }
          ]
        },
        {
          type: :fields,
          value: {
            "fields" => {
              type: :block,
              value: [
                { type: :span, value: "A hash containing metadata to be included in logs emitted by this instance.\n" }
              ]
            },
            "format" => {
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
        },
        {
          type: :block,
          value: [
            { type: :span, value: "Each instance exposes the following methods, which accepts an arbitrary\nnumber of key-value pairs to be included in the logged message:" }
          ]
        },
        {
          type: :block,
          value: [
            { class_path: nil, name: "error", target: nil, type: :method_ref, value: "#error(msg, error=nil, **fields)" },
            { type: :span, value: ": Outputs an error entry. When `error` is\n  present, attempts to obtain backtrace information and also includes it\n  to the emitted entry." }
          ]
        },
        {
          type: :block,
          value: [
            { class_path: nil, name: "fatal", target: nil, type: :method_ref, value: "#fatal(msg, **fields)" },
            { type: :span, value: ": Outputs a fatal entry. Calling fatal causes the\n  current process to exit with a status 1." }
          ]
        },
        {
          type: :block,
          value: [
            { class_path: nil, name: "warn", target: nil, type: :method_ref, value: "#warn(msg, **fields)" },
            { type: :span, value: ": Outputs a warning entry.\n" },
            { class_path: nil, name: "info", target: nil, type: :method_ref, value: "#info(msg, **fields)" },
            { type: :span, value: ": Outputs a informational entry.\n" },
            { class_path: nil, name: "debug", target: nil, type: :method_ref, value: "#debug(msg, **fields)" },
            { type: :span, value: ": Outputs a debug entry.\n" },
            { class_path: nil, name: "dump", target: nil, type: :method_ref, value: "#dump(msg, data=nil)" },
            { type: :span, value: ": Outputs a given String or Array of bytes using the\n  same format as `hexdump -C`." }
          ]
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses method comments without fields" do
    input = <<~DOC
      # Internal: Formats a given text using the ANSI escape sequences. Notice
      # that this method does not attempt to determine whether the current output
      # supports escape sequences.
    DOC

    output = {
      meta: { visibility: "Internal" },
      value: [
        {
          type: :block,
          value: [
            { type: :span, value: "Formats a given text using the ANSI escape sequences. Notice\nthat this method does not attempt to determine whether the current output\nsupports escape sequences." }
          ]
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses method comments with fields" do
    input = <<~DOC
      # Internal: Logs a text entry to the current output.
      #
      # level       - The severity of the message to be logged.
      # msg         - The message to be logged
      # error       - Either an Exception object or nil. This parameter is used
      #               to provide extra information on the logged entry.
      # fields      - A Hash containing metadata to be included in the logged
      #               entry.
      # caller_meta - An Array containing the caller's location and name.
    DOC

    output = {
      meta: { visibility: "Internal" },
      value: [
        {
          type: :block,
          value: [
            { type: :span, value: "Logs a text entry to the current output." }
          ]
        },
        {
          type: :fields,
          value: {
            "caller_meta" => {
              type: :block,
              value: [
                { type: :span, value: "An Array containing the caller's location and name." }
              ]
            },
            "error" => {
              type: :block,
              value: [
                { type: :span, value: "Either an Exception object or nil. This parameter is used to provide extra information on the logged entry.\n" }
              ]
            },
            "fields" => {
              type: :block,
              value: [
                { type: :span, value: "A Hash containing metadata to be included in the logged entry.\n" }
              ]
            },
            "level" => {
              type: :block,
              value: [
                { type: :span, value: "The severity of the message to be logged." }
              ]
            },
            "msg" => {
              type: :block,
              value: [
                { type: :span, value: "The message to be logged" }
              ]
            }
          }
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses references" do
    input = <<~DOC
      # Public: Emits a fatal message to the log output, and invokes Kernel#exit
      # with a non-zero status code. When error is provided, this method attempts
      # to gather a stacktrace to include in the emitted entry. This log entry
      # cannot be filtered, and is always emitted.
    DOC

    output = {
      meta: { visibility: "Public" },
      value: [
        {
          type: :block,
          value: [
            { type: :span, value: "Emits a fatal message to the log output, and invokes " },
            { class_path: "", name: "exit", target: "Kernel", type: :method_ref, value: "Kernel#exit" },
            { type: :span, value: "\nwith a non-zero status code. When error is provided, this method attempts\nto gather a stacktrace to include in the emitted entry. This log entry\ncannot be filtered, and is always emitted." }
          ]
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end
end
