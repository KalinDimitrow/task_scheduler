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
end
