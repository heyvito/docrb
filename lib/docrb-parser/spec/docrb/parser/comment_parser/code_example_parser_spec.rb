# frozen_string_literal: true

RSpec.describe Docrb::Parser::CommentParser do
  it "detects code examples" do
    input = <<~DOC
      # GenericHandler is lorem ipsum dolor sit amet, consectetur adipiscing elit.
      # Nulla maximus eu metus eget iaculis. Ut velit nunc, scelerisque nec nibh
      # ut, hendrerit pellentesque libero. Ut vitae scelerisque enim, id consequat
      # massa. Curabitur vel sagittis purus. Donec dapibus condimentum malesuada.
      # Donec sapien odio, pretium nec porta in, mollis eu ex. Duis ornare mauris
      # elit, eu bibendum ex feugiat a. Donec aliquam ultrices elit, vitae
      # tristique quam molestie a. Praesent mattis nulla quis sollicitudin rutrum.
      # Nullam ut sodales nulla.
      #
      #   class PingHandler < GenericHandler
      #     handler_for "ping"
      #
      #     handle do
      #       print("Pong!")
      #     end
      #   end
    DOC

    output = {
      meta: {},
      value: [
        {
          type: :block,
          value: [
            { type: :identifier, value: "GenericHandler" },
            {
              type: :span,
              value: " is lorem ipsum dolor sit amet, consectetur adipiscing elit.\nNulla maximus eu metus eget iaculis. Ut velit nunc, scelerisque nec nibh\nut, hendrerit pellentesque libero. Ut vitae scelerisque enim, id consequat\nmassa. Curabitur vel sagittis purus. Donec dapibus condimentum malesuada.\nDonec sapien odio, pretium nec porta in, mollis eu ex. Duis ornare mauris\nelit, eu bibendum ex feugiat a. Donec aliquam ultrices elit, vitae\ntristique quam molestie a. Praesent mattis nulla quis sollicitudin rutrum.\nNullam ut sodales nulla."
            }
          ]
        },
        {
          source: "class PingHandler < GenericHandler\n\n  handler_for \"ping\"\n\n  handle do\n\n    print(\"Pong!\")\n\n  end\n\nend\n",
          type: :code_example
        }
      ]
    }

    data = described_class.parse(input)
    expect(data).to eq(output)
  end
end
