# Converts value to hash recursively
module Hashify
  def self.[](value)
    if value.respond_to?(:to_hash)
      value.to_hash
    elsif value.respond_to?(:map)
      value.map { |item| self[item] }
    else
      value
    end
  end
end
