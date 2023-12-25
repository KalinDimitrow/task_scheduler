# frozen_string_literal: true

class SimpleTask
  attr_reader :depends_on, :produce, :run_on

  def initialize
    @objects_hash = {
      'simple_task2': %w[step1 step2],
      'simple_task3': %w[step1 step2]
    }

    @produce = {}

    @run_on = ''
  end

  def process; end
end
