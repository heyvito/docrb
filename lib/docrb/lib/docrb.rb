# frozen_string_literal: true

require "parser/current"
require "forwardable"
require "json"
require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"
require "rubygems"

Parser::Builders::Default.emit_lambda              = true
Parser::Builders::Default.emit_procarg0            = true
Parser::Builders::Default.emit_encoding            = true
Parser::Builders::Default.emit_index               = true
Parser::Builders::Default.emit_arg_inside_procarg0 = true
Parser::Builders::Default.emit_forward_arg         = true
Parser::Builders::Default.emit_kwargs              = true
Parser::Builders::Default.emit_match_pattern       = true

require_relative "docrb/version"
require_relative "docrb/ruby_parser"
require_relative "docrb/module_extensions"

# Docrb implements a source and documentation parser for Ruby projects
module Docrb
  # Error class from which all other Docrb errors derive from
  class Error < StandardError; end

  autoload :CommentParser, "docrb/comment_parser"
  autoload :DocCompiler, "docrb/doc_compiler"
  autoload :Resolvable, "docrb/resolvable"
  autoload :Markdown, "docrb/markdown"
  autoload :Spec, "docrb/spec"

  # Public: Parses a single file under a provided path
  #
  # path - Path to the file to be parsed
  #
  # Returns an object representing the parsed source and documentation
  def self.parse(path)
    inst = RubyParser.new(path)
    inst.parse
    inst
  end

  # Public: Parses a given input folder recursivelly and returns all sources
  # and documentations
  #
  # inp - Folder to be parsed. Finds all .rb files recursivelly from this path.
  #
  # Returns an array with all parsed files
  def self.parse_folder(inp)
    output = []
    Dir["#{inp}/**/*.rb"].each do |f|
      inst = parse(f)
      inst.classes.each do |c|
        c[:filename] = f
        output << c
      end
      inst.modules.each do |c|
        c[:filename] = f
        output << c
      end
      inst.methods.each do |c|
        c[:filename] = f
        output << c
      end
    end
    output
  end
end
