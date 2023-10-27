# frozen_string_literal: true

class Object
  def own_methods = methods.sort - Object.methods
  def object_id_hex = "0x#{object_id.to_s(16).rjust(16, "0")}"

  def self.docrb_inspect(&)
    return if @__inspect__installed__

    @__inspect__installed__ = true
    define_method(:to_s) { "<#{self.class.name}:#{object_id_hex} #{instance_exec(&)}>" }
    define_method(:inspect) { to_s }
  end

  def try(method, *, **, &)
    return nil unless respond_to? method

    send(method, *, **, &)
  end

  def attr_list(*names)
    names.map { "#{_1}: #{send(_1).inspect}" }.join(", ")
  end

  def self.docrb_inspect_attrs(*)
    @inspectable_attrs = superclass.instance_variable_get(:@inspectable_attrs).dup || [] if @inspectable_attrs.nil?
    @inspectable_attrs.append(*)
    docrb_inspect { attr_list(*self.class.instance_variable_get(:@inspectable_attrs)) }
  end

  def self.visible_attr_reader(*)
    attr_reader(*)

    docrb_inspect_attrs(*)
  end

  def self.visible_attr_accessor(*)
    attr_accessor(*)

    docrb_inspect_attrs(*)
  end
end

class Array
  def first!
    first or raise("#first! called on empty array")
  end

  alias old_first first

  def first(*, **, &)
    return old_first(*, **) unless block_given?

    lazy.map(&).filter(&:itself).first
  end
end

module Kernel
  def then! = nil? ? nil : yield(self)
end
