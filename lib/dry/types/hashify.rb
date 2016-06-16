# Converts value to hash recursively
class Hashify
  def self.[](value)
    new(value).call
  end

  def initialize(value)
    @value = value
  end

  def call
    if @value.respond_to?(:to_hash)
      @value.to_hash
    elsif @value.respond_to?(:map)
      @value.map { |item| self.class[item] }
    else
      @value
    end
  end
end
