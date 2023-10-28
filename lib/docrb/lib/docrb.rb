# frozen_string_literal: true

require "json"
require "rubygems"

require "docrb-html"
require "docrb-parser"

require_relative "docrb/version"
require_relative "docrb/spec"
require_relative "docrb/doc_compiler"

# Docrb implements a source and documentation parser for Ruby projects
module Docrb
  # Error class from which all other Docrb errors derive from
  class Error < StandardError; end

  # Public: Parses a given input folder recursively and returns all sources
  # and documentations
  #
  # inp - Folder to be parsed. Finds all .rb files recursively from this path.
  #
  # Returns a NodeArray with parsed nodes.
  def self.parse_folder(base, input)
    source = Docrb::Parser
      .new
      .tap { |parser| Dir["#{base}/**/*.rb"].each { parser.parse(_1) } }
      .tap(&:finalize)
    spec = Spec.parse_folder(input)

    [source, spec]
  end
end
