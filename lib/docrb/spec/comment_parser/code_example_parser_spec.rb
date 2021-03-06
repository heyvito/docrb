# frozen_string_literal: true

RSpec.describe Docrb::CommentParser do
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
      type: :method,
      contents: [
        {
          type: :text_block,
          contents: [
            { type: :camelcase_identifier, contents: "GenericHandler" },
            { type: :span, contents: [
              " is lorem ipsum dolor sit amet, consectetur adipiscing elit.",
              "Nulla maximus eu metus eget iaculis. Ut velit nunc, scelerisque nec nibh",
              "ut, hendrerit pellentesque libero. Ut vitae scelerisque enim, id consequat",
              "massa. Curabitur vel sagittis purus. Donec dapibus condimentum malesuada.",
              "Donec sapien odio, pretium nec porta in, mollis eu ex. Duis ornare mauris",
              "elit, eu bibendum ex feugiat a. Donec aliquam ultrices elit, vitae",
              "tristique quam molestie a. Praesent mattis nulla quis sollicitudin rutrum.",
              "Nullam ut sodales nulla.",
              ""
              ].join("\n") }
          ]
        },
        {
          type: :code_example,
          contents: [
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

    data = described_class.parse(type: :method, comment: input)
    expect(data).to eq(output)
  end
end
