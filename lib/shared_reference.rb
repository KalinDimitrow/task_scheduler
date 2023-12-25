# frozen_string_literal: true

class SharedReference
  attr_accessor :value

  def initialize(value)
    @value = value
  end
end
