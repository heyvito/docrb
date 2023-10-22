# frozen_string_literal: true

module Docrb
  class Parser
    class Reloader
      def self.reload!
        Object.send(:remove_const, :Docrb) if defined? Docrb

        root_dir = File.expand_path("../..", __dir__)
        $LOADED_FEATURES
          .select { _1.start_with? root_dir }
          .each { $LOADED_FEATURES.delete _1 }

        require "docrb/parser"
        true
      end
    end
  end
end
