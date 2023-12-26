require_relative '../../lib/strategies/topsort_utils'
require_relative '../../lib/strategies/topsort_utils_with_connected_components'
require_relative '../../lib/shared_reference'

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
