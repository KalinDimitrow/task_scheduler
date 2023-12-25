# frozen_string_literal: true

module DependencyGraphStrategies
  # Generalization for Topological Sort strategies
  module TopSortBase
    BacktrackData = Struct.new(:vertex, :edges) {}

    attr_reader :graph
    attr_accessor :stack, :metadata, :partial_data, :result

    def initialize(graph)
      @graph = graph
      @stack = []
      @partial_data = {}
      @partial_data.default_proc = proc { [] }
      @result = []
      @metadata = graph.transform_values { self.class.util_data }
    end

    def back_track_data(vertex, edges)
      BacktrackData.new(vertex, edges)
    end
  end

  # The `TopSortUtils` class provides utility methods for managing topological
  # sort operations on graphs. It handles tasks such as processing vertices, maintaining
  # graph metadata, and finalizing the results of a sort. The methods in this class
  # accept and interact with graph structures and related data.
  #
  # @note The class is intended to be used for sorting directed acyclic graphs; it doesn't handle cyclic graphs.
  class TopSortUtils
    UtilData = Struct.new(:processed, :traced) {}
    BacktrackData = Struct.new(:vertex, :edges) {}
    include TopSortBase

    def self.util_data
      UtilData.new(false, false)
    end

    def preprocess(vertex, edges)
      metadata[vertex].traced = true
      not_processed_edges = []
      edges.each do |edge|
        next if metadata[edge].processed
        raise 'circular dependency' if metadata[edge].traced

        not_processed_edges.push(BacktrackData.new(edge, graph[edge]))
      end

      return true if not_processed_edges.empty?

      stack.push(*not_processed_edges)
      false
    end

    def process(current, _, _, sorted)
      sorted << current.vertex
      stack.pop
      metadata[current.vertex].traced = false
      metadata[current.vertex].processed = true
      current
    end

    def accumulate(sorted)
      @result += sorted
    end

    def finalize
      result
    end
  end

  # The `TopSortWithConnectedComponentsUtils` class extends the `TopSortUtils` class with specific
  # behavior for topological sorting of graph structures with multiple connected components.
  # This class ensures that all components, whether connected or disconnected, get processed separately yet in a correct order.
  #
  # @note The class is intended to be used for sorting directed acyclic graphs; it doesn't handle cyclic graphs.
  class TopSortWithConnectedComponentsUtils
    UtilData = Struct.new(:processed, :traced, :set, :left, :right) {}
    BacktrackData = Struct.new(:vertex, :edges) {}
    PartialData = Struct.new(:accumulated) {}

    include TopSortBase

    def self.util_data
      UtilData.new(false, false, SharedReference.new(nil), 0, 0)
    end

    def preprocess(vertex, edges)
      result = true
      metadata[vertex].traced = true
      visited_nodes = []
      min_index = nil
      edges.each do |edge|
        if metadata[edge].processed
          # potential place for optimization, this list could be reduced to single element
          # 1 the whole set could share the same object containing the index
          # 2 because we visit the vertex we can maintain property that all already visited vertices share the same index
          visited_nodes << edge
          metadata[edge].left += 1
          min_index = min_index.nil? || min_index > metadata[edge].set ? metadata[edge].set : min_index
        else
          result &&= false
          # if consequential vertices are traced but not visited that mean we have circular dependency
          # vertex is considered traced just before being preprocessed and become untraced again after being processed
          # vertex become visited after being processed
          raise 'circular dependency' if metadata[edge].traced

          # push on the stack to process later
          stack.push(BacktrackData.new(edge, graph[edge]))
        end
      end

      # Equalize the component index in between the members of that component
      # If min_index is nil mean that vertex is the first member of the component so far for the current iteration of dfs,
      # in that case the value will be given later in process function
      unless min_index.nil?
        metadata[vertex].set = min_index
        visited_nodes.each { |e| metadata[e].set.value = min_index.value }
      end

      result
    end

    def process(current, back_track_data, index, sorted)
      update_set_value(back_track_data, current, index)
      sorted.push(current.vertex)
      stack.pop
      metadata[current.vertex].right = graph[current.vertex].length
      metadata[current.vertex].processed = true
      metadata[current.vertex].traced = false
      current
    end

    def accumulate(sorted)
      partial_data[metadata[sorted.first].set.value] += sorted
    end

    def finalize
      partial_data.keys.sort.each_with_index.map do |key, index|
        [index, partial_data[key]]
      end.to_h
    end

    private

    # rubocop:disable Metrics/AbcSize
    def update_set_value(back_track_data, current, index)
      if back_track_data.nil?
        metadata[current.vertex].set.value = index if metadata[current.vertex].set.value.nil?
      else
        metadata[current.vertex].set = metadata[back_track_data.vertex].set
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
