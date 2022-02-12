# frozen_string_literal: true

require_relative '../lib/tic_tac_toe'

describe Board do
  describe '#place' do
    subject(:board) { described_class.new }

    context 'symbols placed correctly on empty spots' do

      it 'places a correct O symbol in the correct place' do
        expect { board.place('O', 5) }.to change { board.board[1][1] }.to eq('O')
      end

      it 'places a correct X symbol in the correct place' do
        expect { board.place('X', 3) }.to change { board.board[0][2] }.to eq('X')
      end
    end

    context 'symbols placed on other symbols' do
      it 'does not replace a previously placed symbol' do
        board.place('O', 7)
        expect { board.place('X', 7) }.not_to change { board.board }
      end
    end

    context 'incorrect inputs' do
      it "does not place a symbol that isn't X or O" do
        expect { board.place('Y', 7) }.not_to change { board.board }
      end

      it 'does not place a symbol with a location < 1' do
        expect { board.place('X', 0) }.not_to change { board.board }
      end

      it 'does not place a symbol with a location > 9' do
        expect { board.place('O', 10) }.not_to change { board.board }
      end
    end
  end

  describe '#undo_place' do
    subject(:board) { described_class.new }

    context 'when the removed cell has a symbol on it' do
      it 'removes the symbol and replaces it with the appropriate number' do
        board.place('X', 7)
        expect { board.undo_place(7) }.to change { board.board[2][0] }.to eq('7')
      end
    end

    context 'when the removed cell does not have a symobl on it' do
      it 'does nothing' do
        expect { board.undo_place(2) }.not_to change { board.board }
      end
    end

    context 'when the location is incorrect' do
      it 'does nothing' do
        expect { board.undo_place(10) }.not_to change { board.board }
      end
    end
  end

  describe '#correct_placement' do
    # This is tested well enough by #place tests
  end

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

      it 'returns X when the middle column is filled with X' do
        board_x.place('X', 2)
        board_x.place('X', 5)
        board_x.place('X', 8)
        result = board_x.detect_winner
        expect(result).to eq('X')
      end

      it 'returns X when the top-left to bottom-right diagonal is filled with X' do
        board_x.place('X', 1)
        board_x.place('X', 5)
        board_x.place('X', 9)
        result = board_x.detect_winner
        expect(result).to eq('X')
      end
    end

    context 'when O has won' do
      subject(:board_o) { described_class.new }

      it 'returns O when the top row is filled with O' do
        board_o.place('O', 1)
        board_o.place('O', 2)
        board_o.place('O', 3)
        result = board_o.detect_winner
        expect(result).to eq('O')
      end

      it 'returns O when the middle column is filled with O' do
        board_o.place('O', 2)
        board_o.place('O', 5)
        board_o.place('O', 8)
        result = board_o.detect_winner
        expect(result).to eq('O')
      end

      it 'returns O when the top-left to bottom-right diagonal is filled with O' do
        board_o.place('O', 1)
        board_o.place('O', 5)
        board_o.place('O', 9)
        result = board_o.detect_winner
        expect(result).to eq('O')
      end
    end

    context 'when no one has won' do
      subject(:board) { described_class.new }

      it 'returns nil for an empty board' do
        result = board.detect_winner
        expect(result).to eq(nil)
      end

      it 'returns nil after 4 moves' do
        board.place('X', 5)
        board.place('O', 2)
        board.place('X', 6)
        board.place('O', 4)
        result = board.detect_winner
        expect(result).to eq(nil)
      end

      it 'returns tie in the event of a tie' do
        board.place('X', 1)
        board.place('O', 2)
        board.place('X', 3)
        board.place('O', 4)
        board.place('X', 6)
        board.place('O', 5)
        board.place('X', 8)
        board.place('O', 9)
        board.place('X', 7)
        result = board.detect_winner
        expect(result).to eq('tie')
      end
    end
  end
end
