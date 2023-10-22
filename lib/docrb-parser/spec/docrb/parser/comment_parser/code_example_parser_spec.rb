# frozen_string_literal: true

RSpec.describe Docrb::Parser::CommentParser do
  it "detects code examples" do
    input = <<~DOC
      GenericHandler is lorem ipsum dolor sit amet, consectetur adipiscing elit.
      Nulla maximus eu metus eget iaculis. Ut velit nunc, scelerisque nec nibh
      ut, hendrerit pellentesque libero. Ut vitae scelerisque enim, id consequat
      massa. Curabitur vel sagittis purus. Donec dapibus condimentum malesuada.
      Donec sapien odio, pretium nec porta in, mollis eu ex. Duis ornare mauris
      elit, eu bibendum ex feugiat a. Donec aliquam ultrices elit, vitae
      tristique quam molestie a. Praesent mattis nulla quis sollicitudin rutrum.
      Nullam ut sodales nulla.

        class PingHandler < GenericHandler
          handler_for "ping"

          handle do
            print("Pong!")
          end
        end
    DOC

    output = {
      meta: {},
      value: [
        { type: :camel_case_identifier, value: "GenericHandler" },
        { type: :text_block, value: [
          " is lorem ipsum dolor sit amet, consectetur adipiscing elit.",
          "Nulla maximus eu metus eget iaculis. Ut velit nunc, scelerisque nec nibh",
          "ut, hendrerit pellentesque libero. Ut vitae scelerisque enim, id consequat",
          "massa. Curabitur vel sagittis purus. Donec dapibus condimentum malesuada.",
          "Donec sapien odio, pretium nec porta in, mollis eu ex. Duis ornare mauris",
          "elit, eu bibendum ex feugiat a. Donec aliquam ultrices elit, vitae",
          "tristique quam molestie a. Praesent mattis nulla quis sollicitudin rutrum.",
          "Nullam ut sodales nulla.",
          ""
        ].join("\n") },
        {
          type: :code_example_block,
          value: [
            "class PingHandler < GenericHandler",
            "  handler_for \"ping\"",
            "",
            "  handle do",
            "    print(\"Pong!\")",
            "  end",
            "end"
          ].join("\n")
        }
      ]
    }

    data = described_class.parse(input)
    expect(data).to eq(output)
  end
end
