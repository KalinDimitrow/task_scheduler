# frozen_string_literal: true

require './lib/dependency_graph'

class TaskManager
  attr_reader :tasks

  def initialize(task_directory: './tasks')
    raise "Directory \"#{task_directory}\" do not exist" unless File.directory?(task_directory)

    @tasks = load_tasks task_directory
    preprocess(tasks)
  end

  # private
  def preprocess(tasks); end

  def task?(obj)
    obj.respond_to?(:new) &&
      obj.method_defined?(:process) &&
      obj.method_defined?(:depends_on) &&
      obj.method_defined?(:produce) &&
      obj.method_defined?(:run_on)
  end

  def check_tasks(candidates)
    candidates.map do |t|
      # puts "Not suitable task #{c.inspect}"
      raise "Not suitable task: #{t.inspect}" unless task?(t)

      t
    end
  end

  def load_tasks(task_directory)
    old_classes = ObjectSpace.each_object(Class).to_a
    Dir["#{task_directory}/*.rb"].map do |file|
      require file
      new_classes = ObjectSpace.each_object(Class).to_a
      loaded_classes = new_classes - old_classes
      non_anonymous_new_classes = loaded_classes.find_all(&:name)
      old_classes = new_classes # .map(&:new)
      check_tasks(non_anonymous_new_classes)
    end
  end

  def solver(input)
    DependencySolver.solve(input)
  end
end
