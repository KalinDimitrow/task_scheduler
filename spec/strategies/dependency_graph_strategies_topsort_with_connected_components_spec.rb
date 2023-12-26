# frozen_string_literal: true

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
