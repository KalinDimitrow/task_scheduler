
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