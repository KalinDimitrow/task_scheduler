# frozen_string_literal: true

require './lib/dependency_graph'

RSpec.describe DependencyGraph do
  describe '.top_sort' do
    context 'when provided input contain self referencing vertex' do
      it 'throw exception' do
        input = {
          1 => [1]
        }
        expect { described_class.top_sort(input) }.to raise_error('circular dependency')
      end
    end
    context 'when provided input contain longer cycle' do
      it 'throw exception' do
        input = {
          1 => [2],
          2 => [3],
          3 => [1]
        }
        expect { described_class.top_sort(input) }.to raise_error('circular dependency')
      end
    end
    context 'when provided input contain tree like graph' do
      it 'return topologically sorted list' do
        input = {
          'a' => ['g'],
          'b' => ['g'],
          'c' => ['a'],
          'd' => ['a'],
          'e' => ['b'],
          'f' => ['b'],
          'g' => []
        }

        expected_result = %w[g a b c d e f]
        expect(described_class.top_sort(input)).to match(expected_result)
      end
    end

    context 'when provided forest like graph' do
      it 'return hash of weakly connected components' do
        input = {
          # first tree
          '1' => ['7'],
          '2' => ['7'],
          '3' => ['1'],
          '4' => ['1'],
          '5' => ['2'],
          '6' => ['2'],
          '7' => [],
          # second tree
          '8' => ['10'],
          '9' => ['10'],
          '10' => []
        }

        expected_result = %w[7 1 2 3 4 5 6 10 8 9]
        expect(described_class.top_sort(input)).to match(expected_result)
      end
    end
  end
  describe '.top_sort_with_connected_components' do
    context 'when provided input contain self referencing vertex' do
      it 'throw exception' do
        input = {
          'vertex' => ['vertex']
        }
        expect { described_class.top_sort_with_connected_components(input) }.to raise_error('circular dependency')
      end
    end
    context 'when provided input contain longer cycle' do
      it 'throw exception' do
        input = {
          'vertex1' => ['vertex2'],
          'vertex2' => ['vertex3'],
          'vertex3' => ['vertex1']
        }
        expect { described_class.top_sort_with_connected_components(input) }.to raise_error('circular dependency')
      end
    end
    context 'when provided input contain tree like graph' do
      it 'return topologically sorted list' do
        input = {
          'a' => ['g'],
          'b' => ['g'],
          'c' => ['a'],
          'd' => ['a'],
          'e' => ['b'],
          'f' => ['b'],
          'g' => []
        }

        expected_result = { 0 => %w[g a b c d e f] }
        expect(described_class.top_sort_with_connected_components(input)).to match(expected_result)
      end
    end
    context 'when provided forest like graph' do
      it 'return hash of weakly connected components' do
        input = {
          # first tree
          '1' => ['7'],
          '2' => ['7'],
          '3' => ['1'],
          '4' => ['1'],
          '5' => ['2'],
          '6' => ['2'],
          '7' => [],
          # second tree
          '8' => ['10'],
          '9' => ['10'],
          '10' => []
        }

        expected_result = { 0 => %w[7 1 2 3 4 5 6], 1 => %w[10 8 9] }
        expect(described_class.top_sort_with_connected_components(input)).to match(expected_result)
      end
    end
  end
end
