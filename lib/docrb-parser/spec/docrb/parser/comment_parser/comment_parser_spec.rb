# frozen_string_literal: true

RSpec.describe Docrb::Parser::CommentParser do
  it "parses class comments" do
    input = <<~DOC
      Logrb provides a facility for working with logs in text and json formats.
      All instances share a single mutex to ensure logging consistency.
      The following attributes are available:

      fields - A hash containing metadata to be included in logs emitted by this
               instance.
      level  - The level filter for the instance. Valid values are :error, :fatal,
               :info, :warn, and :debug
      format - The format to output logs. Supports :text and :json.

      Each instance exposes the following methods, which accepts an arbitrary
      number of key-value pairs to be included in the logged message:

      #error(msg, error=nil, **fields): Outputs an error entry. When `error` is
        present, attempts to obtain backtrace information and also includes it
        to the emitted entry.

      #fatal(msg, **fields): Outputs a fatal entry. Calling fatal causes the
        current process to exit with a status 1.

      #warn(msg, **fields): Outputs a warning entry.
      #info(msg, **fields): Outputs a informational entry.
      #debug(msg, **fields): Outputs a debug entry.
      #dump(msg, data=nil): Outputs a given String or Array of bytes using the
        same format as `hexdump -C`.
    DOC

    output = {
      meta: {},
      value: [
        {
          type: :text_block,
          value: "Logrb provides a facility for working with logs in text and json formats.\nAll instances share a single mutex to ensure logging consistency.\nThe following attributes are available:\n"
        },
        {
          type: :field_block,
          value: {
            "fields" => [
              {
                type: :text_block,
                value: "A hash containing metadata to be included in logs emitted by this instance."
              }
            ],
            "level" => [
              {
                type: :text_block,
                value: "The level filter for the instance. Valid values are "
              },
              {
                type: :symbol,
                value: ":error"
              },
              {
                type: :text_block,
                value: ", "
              },
              {
                type: :symbol,
                value: ":fatal"
              },
              {
                type: :text_block,
                value: ", "
              },
              {
                type: :symbol,
                value: ":info"
              },
              {
                type: :text_block,
                value: ", "
              },
              {
                type: :symbol,
                value: ":warn"
              },
              {
                type: :text_block,
                value: ", and "
              },
              {
                type: :symbol,
                value: ":debug"
              }
            ],
            "format" => [
              {
                type: :text_block,
                value: "The format to output logs. Supports "
              },
              {
                type: :symbol,
                value: ":text"
              },
              {
                type: :text_block,
                value: " and "
              },
              {
                type: :symbol,
                value: ":json"
              },
              {
                type: :text_block,
                value: "."
              }
            ]
          }
        },
        {
          type: :text_block,
          value: "Each instance exposes the following methods, which accepts an arbitrary\nnumber of key-value pairs to be included in the logged message:\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "error",
          value: "#error(msg, error=nil, **fields)"
        },
        {
          type: :text_block,
          value: ": Outputs an error entry. When `error` is\n  present, attempts to obtain backtrace information and also includes it\n  to the emitted entry.\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "fatal",
          value: "#fatal(msg, **fields)"
        },
        {
          type: :text_block,
          value: ": Outputs a fatal entry. Calling fatal causes the\n  current process to exit with a status 1.\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "warn",
          value: "#warn(msg, **fields)"
        },
        {
          type: :text_block,
          value: ": Outputs a warning entry.\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "info",
          value: "#info(msg, **fields)"
        },
        {
          type: :text_block,
          value: ": Outputs a informational entry.\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "debug",
          value: "#debug(msg, **fields)"
        },
        {
          type: :text_block,
          value: ": Outputs a debug entry.\n"
        },
        {
          type: :reference,
          ref_type: :method,
          name: "dump",
          value: "#dump(msg, data=nil)"
        },
        {
          type: :text_block,
          value: ": Outputs a given String or Array of bytes using the\n  same format as `hexdump -C`.\n"
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses method comments without fields" do
    input = <<~DOC
      Internal: Formats a given text using the ANSI escape sequences. Notice
      that this method does not attempt to determine whether the current output
      supports escape sequences.
    DOC

    output = {
      meta: { visibility_annotation: :internal },
      value: [
        {
          type: :text_block,
          value: " Formats a given text using the ANSI escape sequences. Notice\nthat this method does not attempt to determine whether the current output\nsupports escape sequences.\n"
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses method comments with fields" do
    input = <<~DOC
      Internal: Logs a text entry to the current output.

      level       - The severity of the message to be logged.
      msg         - The message to be logged
      error       - Either an Exception object or nil. This parameter is used
                    to provide extra information on the logged entry.
      fields      - A Hash containing metadata to be included in the logged
                    entry.
      caller_meta - An Array containing the caller's location and name.
    DOC

    output = {
      meta: { visibility_annotation: :internal },
      value: [
        {
          value: " Logs a text entry to the current output.\n",
          type: :text_block
        },
        {
          value: {
            "caller_meta" => [{
              value: "An Array containing the caller's location and name.",
              type: :text_block
            }],
            "error" => [{
              value: "Either an Exception object or nil. This parameter is used to provide extra information on the logged entry.",
              type: :text_block
            }],
            "fields" => [{
              value: "A Hash containing metadata to be included in the logged entry.",
              type: :text_block
            }],
            "level" => [{
              value: "The severity of the message to be logged.",
              type: :text_block
            }],
            "msg" => [{
              value: "The message to be logged",
              type: :text_block
            }]
          },
          type: :field_block
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end

  it "parses references" do
    input = <<~DOC
      Public: Emits a fatal message to the log output, and invokes Kernel#exit
      with a non-zero status code. When error is provided, this method attempts
      to gather a stacktrace to include in the emitted entry. This log entry
      cannot be filtered, and is always emitted.
    DOC

    output = {
      meta: { visibility_annotation: :public },
      value: [
        {
          type: :text_block,
          value: " Emits a fatal message to the log output, and invokes "
        },
        {
          type: :reference,
          value: "Kernel#exit",
          name: "exit",
          ref_type: :method,
          target: "Kernel"
        },
        {
          type: :text_block,
          value: "\nwith a non-zero status code. When error is provided, this method attempts\nto gather a stacktrace to include in the emitted entry. This log entry\ncannot be filtered, and is always emitted.\n"
        }
      ]
    }

    expect(described_class.parse(input)).to eq(output)
  end
end
