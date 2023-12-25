# frozen_string_literal: true

# require 'docker-api'

require './lib/task_manager'

task_manager = TaskManager.new(task_directory: './tasks')

g = {
  'a' => ['e'],
  'b' => ['e'],
  'c' => ['e'],
  'd' => ['e'],
  'e' => ['e']
}

result = task_manager.solver(g)
p result
