# frozen_string_literal: true

class Shared
  attr_accessor :value

  def initialize(value)
    @value = value
  end
end

class Wrapper
  attr_accessor :shared

  def initialize(shared)
    @shared = shared
  end

  def change(new_value)
    shared.value = new_value
  end

  def print
    puts shared.value
  end

  def clone
    shared
  end
end

# w1 = Wrapper.new(Shared.new(5))
# w2 = Wrapper.new(w1.clone)
#
# w1.print
# w2.print
# w1.change(3)
# w1.print
# w2.print
# w2.change(11)
# w1.print
# w2.print

# h = {}
# h[2] = (h[2] || '') + 'Bananas'

h = {}
h.default_proc = proc { [] }
h[2] += [1, 2]
h[2] += [3, 4]

pp h
