# frozen_string_literal: true

require_relative './topsort_base'

module DependencyGraphStrategies
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
end