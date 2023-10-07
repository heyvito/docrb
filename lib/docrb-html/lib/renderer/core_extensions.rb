# frozen_string_literal: true

class String
  def snakify
    gsub(/::/, "/")
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end
end

class Object
  def object_id_hex = "0x#{object_id.to_s(16).rjust(16, "0")}"
end
