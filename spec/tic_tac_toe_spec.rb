# frozen_string_literal: true

require_relative '../lib/tic_tac_toe'

describe Board do
  describe '#detect_winner' do
    context 'when X has won' do
      subject(:board_x) { described_class.new }

      it 'returns X when the top row is filled with X' do
        board_x.place('X', 1)
        board_x.place('X', 2)
        board_x.place('X', 3)
        result = board_x.detect_winner
        expect(result).to eq('X')
      end
    end
  end
end
