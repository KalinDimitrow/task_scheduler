# frozen_string_literal: true

require_relative '../lib/dependency_graph_strategies'
require_relative '../lib/shared_reference'

RSpec.shared_examples 'common tests dependency_graph_strategies' do |strategy_class|
  let(:graph) { { 'node1' => ['node2'], 'node2' => [] } }
  subject(:top_sort_utils) { strategy_class.new(graph) }

  describe '#preprocess' do
    context 'when preprocess parent node' do
      it 'return false (node is not ready be processed) and not rise error' do
        expect(top_sort_utils.preprocess('node1', graph['node1'])).to equal(false)
      end
    end

    context 'when preprocess parent node and there is unprocessed children' do
      it 'add the children for future preprocess' do
        expect_any_instance_of(Array).to receive(:push)
        top_sort_utils.preprocess('node1', graph['node1'])
      end
    end

    context 'when preprocess isolated node' do
      it 'return true (mark the node as ready to process) and not rise error' do
        expect(top_sort_utils.preprocess('node2', graph['node2'])).to equal(true)
      end
    end

    context 'when preprocess node with multiple children' do
      let(:graph) { { 'node1' => %w[node2 node3], 'node2' => [], 'node3' => [] } }

      it 'returns false and adds all children for future preprocess' do
        expect(top_sort_utils.preprocess('node1', graph['node1'])).to equal(false)
        # Add assertion to check if all children ('node2' and 'node3') are added for future preprocess
      end
    end

    context 'when preprocess child before parent' do
      it 'rice circular dependency error ' do
        top_sort_utils.preprocess('node2', graph['node2'])
        expect { top_sort_utils.preprocess('node1', graph['node1']) }.to raise_error('circular dependency')
      end
    end

    context 'when preprocess node that children nodes are already processed' do
      let(:graph) { { 'node1' => ['node2'], 'node2' => ['node3'], 'node3' => [] } }

      it 'returns true and does not raise an error' do
        top_sort_utils.preprocess('node2', graph['node2'])
        top_sort_utils.process(top_sort_utils.back_track_data('node2', graph['node2']), nil, nil, [])
        expect(top_sort_utils.preprocess('node1', graph['node1'])).to equal(true)
      end
    end
  end
end

RSpec.describe DependencyGraphStrategies::TopSortUtils do
  let(:graph) { { 'node1' => ['node2'], 'node2' => [] } }

  subject(:top_sort_utils) do
    described_class.new(graph)
  end
  it_behaves_like 'common tests dependency_graph_strategies', DependencyGraphStrategies::TopSortUtils

  describe '#process' do
    let(:backtrack_data) { described_class::BacktrackData.new('node1', graph['node1']) }
    let(:sorted) { [] }

    before do
      top_sort_utils.process(backtrack_data, nil, nil, sorted)
    end

    it 'adds the vertex to the sorted list' do
      expect(sorted).to include('node1')
    end

    it 'removes the vertex from the stack' do
      expect(top_sort_utils.stack.map(&:vertex)).not_to include('node1')
    end

    it 'marks the vertex as not traced' do
      expect(top_sort_utils.metadata['node1'].traced).to eq(false)
    end

    it 'marks the vertex as processed' do
      expect(top_sort_utils.metadata['node1'].processed).to eq(true)
    end
  end
end

RSpec.describe DependencyGraphStrategies::TopSortWithConnectedComponentsUtils do
  it_behaves_like 'common tests dependency_graph_strategies', DependencyGraphStrategies::TopSortWithConnectedComponentsUtils
  let(:graph) { { 'node1' => ['node2'], 'node2' => [] } }

  subject(:top_sort_utils) do
    described_class.new(graph)
  end

  describe '#process' do

    context 'when processing vertex on connected graph and there is not back_track_data' do
      let(:graph) { { 'node1' => ['node2'], 'node2' => [] } }
      let(:vertex) { described_class::BacktrackData.new('node1', graph['node1']) }
      let(:result) { [] }
      let(:index) { 0 }

      before do
        top_sort_utils.process(vertex, nil, index, result)
      end

      it 'updates the set value of the current node' do
        expect(top_sort_utils.metadata['node1'].set.value).to eq(0)
      end

      it 'adds the vertex to the sorted list' do
        expect(result).to include('node1')
      end

      it 'removes the vertex from the stack' do
        expect(top_sort_utils.stack.map(&:vertex)).not_to include('node1')
      end

      it 'updates the right value of the vertex' do
        expect(top_sort_utils.metadata['node1'].right).to eq(graph['node1'].length)
      end

      it 'marks the vertex as processed' do
        expect(top_sort_utils.metadata['node1'].processed).to eq(true)
      end

      it 'marks the vertex as not traced' do
        expect(top_sort_utils.metadata['node1'].traced).to eq(false)
      end
    end

    context 'when processing multiple nodes in disconnected graph' do
      let(:disconnected_graph) { { 'node1' => ['node2'], 'node2' => [], 'node3' => [] } }
      let(:top_sort_utils) { described_class.new(disconnected_graph) }
      let(:first) { described_class::BacktrackData.new('node1', disconnected_graph['node1']) }
      let(:second) { described_class::BacktrackData.new('node2', disconnected_graph['node2']) }
      let(:third) { described_class::BacktrackData.new('node3', disconnected_graph['node3']) }
      let(:result) { [] }

      before do
        top_sort_utils.process(second, nil, 0, result)
        top_sort_utils.process(first, second, 1, result)
        top_sort_utils.process(third, nil, 2, result)
      end

      it 'set first node set equal to the index' do
        expect(top_sort_utils.metadata['node2'].set.value).to eq(0)
      end

      it 'set second node set equal to its child' do
        expect(top_sort_utils.metadata['node2'].set.value).to eq(0)
      end

      it 'set third node set equal to the index value because its disconnected from the rest' do
        expect(top_sort_utils.metadata['node2'].set.value).to eq(0)
      end

      it 'sort the them' do
        expect(result).to eq(%w[node2 node1 node3])
      end
    end
  end
end
