RSpec.describe Docrb::CommentParser do
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
      type: :class,
      contents: [
        { type: :text_block, contents: "Logrb provides a facility for working with logs in text and json formats.\nAll instances share a single mutex to ensure logging consistency.\nThe following attributes are available:\n" },
        {
              type: :field_block,
          contents: {
            "fields" => { type: :text_block, contents: "A hash containing metadata to be included in logs emitted by this instance.", },
            "format" => {
              type: :text_block,
              contents: [
                { type: :span, contents: "The format to output logs. Supports ", },
                { type: :sym_ref, contents: ":text", },
                { type: :span, contents: " and ", },
                { type: :sym_ref, contents: ":json", },
                { type: :span, contents: ".", }
              ],
            },
             "level" => {
                  type: :text_block,
              contents: [
                { type: :span, contents: "The level filter for the instance. Valid values are ", },
                { type: :sym_ref, contents: ":error", },
                { type: :span, contents: ", ", },
                { type: :sym_ref, contents: ":fatal", },
                { type: :span, contents: ", ", },
                { type: :sym_ref, contents: ":info", },
                { type: :span, contents: ", ", },
                { type: :sym_ref, contents: ":warn", },
                { type: :span, contents: ", and ", },
                { type: :sym_ref, contents: ":debug", }
              ],
            }
          },
        },
        { type: :text_block, contents: "Each instance exposes the following methods, which accepts an arbitrary\nnumber of key-value pairs to be included in the logged message:\n", },
        {
              type: :text_block,
          contents: [
            { type: :ref, class_path: nil, contents: "#error(msg, error=nil, **fields)", name: "error", ref_type: :method, target: nil, },
            { type: :span, contents: ": Outputs an error entry. When `error` is present, attempts to obtain backtrace information and also includes it to the emitted entry.\n" }
          ],
        },
        {
              type: :text_block,
          contents: [
            { type: :ref, class_path: nil, contents: "#fatal(msg, **fields)", name: "fatal", ref_type: :method, target: nil, },
            { type: :span, contents: ": Outputs a fatal entry. Calling fatal causes the current process to exit with a status 1.\n", }
          ],
        },
        {
              type: :text_block,
          contents: [
            { type: :ref, class_path: nil, contents: "#warn(msg, **fields)", name: "warn", ref_type: :method, target: nil },
            { type: :span, contents: ": Outputs a warning entry.\n" },
            { type: :ref, class_path: nil, contents: "#info(msg, **fields)", name: "info", ref_type: :method, target: nil },
            { type: :span, contents: ": Outputs a informational entry.\n", },
            { type: :ref, class_path: nil, contents: "#debug(msg, **fields)", name: "debug", ref_type: :method, target: nil },
            { type: :span, contents: ": Outputs a debug entry.\n" },
            { type: :ref, class_path: nil, contents: "#dump(msg, data=nil)", name: "dump", ref_type: :method, target: nil },
            { type: :span, contents: ": Outputs a given String or Array of bytes using the same format as `hexdump -C`.\n" }
          ],
        }
      ]
    }

    expect(described_class.parse(type: :class, comment: input)).to eq(output)
  end

  it "parses method comments without fields" do
    input = <<~DOC
      Internal: Formats a given text using the ANSI escape sequences. Notice
      that this method does not attempt to determine whether the current output
      supports escape sequences.
    DOC

    output = {
      type: :method,
      doc_visibility_annotation: :internal,
      contents: [
        {
          type: :text_block,
          contents: "Internal: Formats a given text using the ANSI escape sequences. Notice\nthat this method does not attempt to determine whether the current output\nsupports escape sequences.\n",
        }
      ]
    }

    expect(described_class.parse(type: :method, comment: input)).to eq(output)
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
      type: :method,
      doc_visibility_annotation: :internal,
      contents: [
        {
          contents: "Internal: Logs a text entry to the current output.\n",
          type: :text_block
        },
        {
          contents: {
            "caller_meta" => {
              contents: "An Array containing the caller's location and name.",
              type: :text_block
            },
            "error" => {
              contents: "Either an Exception object or nil. This parameter is used to provide extra information on the logged entry.",
              type: :text_block
            },
            "fields" => {
              contents: "A Hash containing metadata to be included in the logged entry.",
              type: :text_block
            },
            "level" => {
              contents: "The severity of the message to be logged.",
              type: :text_block
            },
            "msg" => {
              contents: "The message to be logged",
              type: :text_block
            }
          },
          type: :field_block
        }
      ],
    }

    expect(described_class.parse(type: :method, comment: input)).to eq(output)
  end

  it "parses references" do
    input = <<~DOC
      Public: Emits a fatal message to the log output, and invokes Kernel#exit
      with a non-zero status code. When error is provided, this method attempts
      to gather a stacktrace to include in the emitted entry. This log entry
      cannot be filtered, and is always emitted.
    DOC

    output = {
      doc_visibility_annotation: :public,
      type: :method,
      contents: [
        {
              type: :text_block,
          contents: [
            { type: :span, contents: "Public: Emits a fatal message to the log output, and invokes ", },
            { type: :ref, class_path: nil, contents: "Kernel#exit", name: "exit", ref_type: :method, target: "Kernel", },
            { type: :span, contents: "\nwith a non-zero status code. When error is provided, this method attempts\nto gather a stacktrace to include in the emitted entry. This log entry\ncannot be filtered, and is always emitted.\n", }
          ],
        }
      ],
    }

    expect(described_class.parse(type: :method, comment: input)).to eq(output)
  end
end
