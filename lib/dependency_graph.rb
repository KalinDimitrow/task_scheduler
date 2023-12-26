# frozen_string_literal: true

require_relative './shared_reference'
require_relative './strategies/topsort_utils'
require_relative './strategies/topsort_utils_with_connected_components'

# The `DependencyGraph` class represents a directed graph, specifically designed to handle and
# manage dependencies between multiple entities or nodes. It provides capabilities to add
# nodes and edges (representing dependencies), checking if nodes are connected, and examining
# the relationships between different nodes.
class DependencyGraph
  class << self
    def top_sort(graph)
      dependency_graph = new(DependencyGraphStrategies::TopSortUtils.new(graph))
      dependency_graph.deep_first_search
    end

    def top_sort_with_connected_components(graph)
      dependency_graph = new(DependencyGraphStrategies::TopSortWithConnectedComponentsUtils.new(graph))
      dependency_graph.deep_first_search
    end
  end

  private

  attr_accessor :utils

  def initialize(utils)
    @utils = utils
  end

  public

  def deep_first_search
    utils.graph.each_with_index do |(vertex, edges), index|
      # if vertex is already processed, we skip it
      next if utils.metadata[vertex].processed

      back_track_data = nil # last processed vertex from previous iteration of the algorithm, emulate the return value of recursive implementation of dfs
      utils.stack.push(utils.back_track_data(vertex, edges))
      sorted = []
      until utils.stack.empty?
        top = utils.stack.last
        has_not_unprocessed_dependencies = utils.preprocess(top.vertex, top.edges)
        back_track_data = utils.process(top, back_track_data, index, sorted) if has_not_unprocessed_dependencies
      end

      utils.accumulate(sorted)
    end
    utils.finalize
  end
end

# class DependencySolver
#   attr_reader :graph
#   attr_accessor :stack, :utils, :partial_data
#
#   UtilData = Struct.new(:visited, :traced, :set, :left, :right) {}
#   BacktrackData = Struct.new(:vertex) {}
#   PartialData = Struct.new(:accumulated) {}
#
#   def self.solve(dependency_graph)
#     instance = new(dependency_graph)
#     instance.solve
#   end
#
#   private
#
#   def initialize(dependency_graph)
#     @graph = dependency_graph
#     @stack = []
#     @utils = dependency_graph.keys.to_h do |key|
#       [key, UtilData.new(false, false, SharedReference.new(nil), 0, 0)]
#     end
#     @partial_data = {}
#     @partial_data.default_proc = proc { [] }
#   end
#
#   public
#
#   def solve
#     # DFS algorithm
#     index = 0
#     graph.each do |vertex, _|
#       current = []
#       next if utils[vertex].visited
#
#       back_track_data = nil # last processed vertex from previous iteration of the algorithm, emulate the return value of recursive implementation of dfs
#       stack.push(BacktrackData.new(vertex))
#       until stack.empty?
#         value = stack.last
#         utils[value.vertex].traced = true
#         has_not_processed_dependencies = preprocess(value)
#         back_track_data = process(value, back_track_data, index, current) if has_not_processed_dependencies
#       end
#       index += 1
#       partial_data[utils[current.first].set.value] += current
#     end
#
#     normalize
#   end
#
#   # Check for circular dependencies and assign unique number to the set of connected components
#   def preprocess(value)
#     result = true
#     visited_nodes = []
#     min_index = nil
#     graph[value.vertex].each do |e|
#       if utils[e].visited
#         # potential place for optimization, this list could be reduced to single element
#         # 1 the whole set could share the same object containing the index
#         # 2 because we visit the vertex we can maintain property that all already visited vertices share the same index
#         visited_nodes << e
#         utils[e].left += 1
#         min_index = min_index.nil? || min_index > utils[e].set ? utils[e].set : min_index
#       else
#         result &&= false
#         # if consequential vertices are traced but not visited that mean we have circular dependency
#         # vertex is considered traced just before being preprocessed and become untraced again after being processed
#         # vertex become visited after being processed
#         raise 'circular dependency' if utils[e].traced
#
#         # push on the stack to process later
#         stack.push(BacktrackData.new(e))
#       end
#     end
#
#     # Equalize the component index in between the members of that component
#     # If min_index is nil mean that vertex is the first member of the component so far for the current iteration of dfs,
#     # in that case the value will be given later in process function
#     unless min_index.nil?
#       utils[value.vertex].set = min_index
#       visited_nodes.each { |e| utils[e].set.value = min_index.value }
#     end
#
#     result
#   end
#
#   def process(value, back_track_data, index, current)
#     if back_track_data.nil?
#       utils[value.vertex].set.value = index if utils[value.vertex].set.value.nil?
#     else
#       utils[value.vertex].set = utils[back_track_data.vertex].set
#     end
#
#     current.push(value.vertex)
#     stack.pop
#     utils[value.vertex].right = graph[value.vertex].length
#     utils[value.vertex].visited = true
#     utils[value.vertex].traced = false
#     value
#   end
#
#   # convert the unique component indices to sequential numbers start from 0 and sort the components
#   # according to those indices
#   def normalize
#     partial_data.keys.sort.each_with_index.map do |key, index|
#       [index, partial_data[key]]
#     end.to_h
#   end
# end
