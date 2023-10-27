# frozen_string_literal: true

module Helpers
  def parse_fixture(id)
    file = find_fixture(id) or raise ArgumentError, "Could not find fixture with id #{id}"

    Docrb::Parser.new.tap { _1.debug = true }.parse(file)
  end

  def find_fixture(id)
    Dir[File.expand_path(File.join(__dir__, "..", "fixtures", "*.rb"))]
      .filter { File.basename(_1) =~ /^\d+_/ }
      .map { { id: /^(\d+)_/.match(File.basename(_1))[1].to_i, path: _1 } }
      .find { _1[:id] == id }
      &.fetch(:path)
  end

  def fixture_named(name) = File.expand_path(File.join(__dir__, "..", "fixtures", name))
end

RSpec::Matchers.define :have_value do
  match do |actual|
    actual.respond_to?(:has_value?) && actual.has_value?
  end
end

RSpec::Matchers.define :have_kind do |expected|
  match do |actual|
    actual.respond_to?(:kind) && actual.kind == expected
  end
end

RSpec::Matchers.define :be_named do |expected|
  match do |actual|
    @actual = (actual.respond_to?(:name) && actual.name) || nil
    values_match? expected, @actual
  end

  diffable
end
