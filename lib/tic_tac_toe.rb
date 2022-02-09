# frozen_string_literal: true

# Game board
class Board
  DIGITS = '123456789'
  MARKS = %w[X O].freeze

  attr_reader :board

  def initialize
    @board = Array.new(3) { Array.new(3) }
    n = 1
    (0..2).each do |i|
      (0..2).each do |j|
        @board[i][j] = n.to_s
        n += 1
      end
    end
  end

  def print_board
    puts "#{@board[0][0]} | #{@board[0][1]} | #{@board[0][2]}"
    puts '---------'
    puts "#{@board[1][0]} | #{@board[1][1]} | #{@board[1][2]}"
    puts '---------'
    puts "#{@board[2][0]} | #{@board[2][1]} | #{@board[2][2]}"
  end

  def place(symbol, location)
    # location expected to be between 1 and 9
    location -= 1
    @board[location / 3][location % 3] = symbol if correct_placement?(symbol, location)
  end

  # For resetting a move
  def undo_place(location)
    # location expected to be between 1 and 9
    location -= 1
    @board[location / 3][location % 3] = (location + 1).to_s
  end

  def correct_placement?(symbol, location)
    # location expected to be between 0 and 8
    return false unless MARKS.include?(symbol)
    return false unless DIGITS.include?((location + 1).to_s)
    return false unless DIGITS.include?(@board[location / 3][location % 3])

    true
  end

  # Returns the symbol of the winner if someone won or 'tie' if there's a tie
  # Returns nil otherwise
  def detect_winner
    (0..2).each do |i|
      return check_row(i) unless check_row(i).nil?
      return check_column(i) unless check_column(i).nil?
    end

    return check_diagonals unless check_diagonals.nil?
    return 'tie' if check_tie

    nil
  end

  private

  def check_row(row)
    return @board[row][0] if @board[row][0] == @board[row][1] && @board[row][0] == @board[row][2]

    nil
  end

  def check_column(col)
    return @board[0][col] if @board[0][col] == @board[1][col] && @board[0][col] == @board[2][col]

    nil
  end

  def check_diagonals
    return @board[0][0] if @board[0][0] == @board[1][1] && @board[0][0] == @board[2][2]
    return @board[0][2] if @board[0][2] == @board[1][1] && @board[0][2] == @board[2][0]

    nil
  end

  def check_tie
    @board.flatten.none? { |cell| DIGITS.include?(cell) }
  end
end

# Human player
class Player
  attr_reader :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end

  def take_turn(board)
    while true
      board.print_board
      print "#{@name} (#{@symbol}), enter your move (1-9): "
      move = gets.chomp.to_i
      puts ''
      break if board.correct_placement?(@symbol, move - 1)
    end

    board.place(@symbol, move)
  end
end

# Computer player
class ComputerPlayer < Player
  def take_turn(board)
    move = get_move(board)
    board.place(@symbol, move)
    puts "#{@name} placed its #{@symbol} on spot #{move}.\n\n"
  end

  private

  def get_move(board)
    best_val = nil
    best_moves = []

    moves = generate_moves(board)
    # When the computer gets to go first
    return (1..9).to_a.sample if moves.length == 9

    moves.each do |move|
      board.place(@symbol, move)
      move_val = minimax(board, 0, false)
      board.undo_place(move)

      if best_val.nil? || move_val > best_val
        best_moves = [move]
        best_val = move_val
      elsif move_val == best_val
        best_moves << move
      end
    end

    # p best_moves

    best_moves.sample
  end

  def generate_moves(board)
    moves = board.board.flatten
    moves.delete(Board::MARKS[0])
    moves.delete(Board::MARKS[1])
    moves.map(&:to_i)
  end

  def evaluate(board)
    return 10 if board.detect_winner == @symbol
    return 0 if board.detect_winner.nil? || board.detect_winner == 'tie'

    -10 # If opponent won the board
  end

  def minimax(board, depth, is_max)
    score = evaluate(board)

    # If maximizer won
    return score - depth if score == 10
    # if minimizer won
    return score + depth if score == -10

    return 0 if board.detect_winner == 'tie'

    opponent_symbol = Board::MARKS[0] if @symbol == Board::MARKS[1]
    opponent_symbol = Board::MARKS[1] if @symbol == Board::MARKS[0]

    if is_max
      best = -1000
      moves = generate_moves(board)
      moves.each do |move|
        board.place(@symbol, move)
        best = [best, minimax(board, depth + 1, !is_max)].max
        board.undo_place(move)
      end
    else
      best = 1000
      moves = generate_moves(board)
      moves.each do |move|
        board.place(opponent_symbol, move)
        best = [best, minimax(board, depth + 1, !is_max)].min
        board.undo_place(move)
      end
    end

    best
  end
end

# Main game class
class Controller
  def initialize
    @b = Board.new
  end

  def start
    puts "Welcome to Tic-Tac-Toe!\n"
    puts 'Please make a selection:'
    puts '1 - Play against another human'
    puts '2 - Play against the computer'

    # This should use exceptions
    while true
      mode = gets.chomp.to_i
      break if [1, 2].include?(mode)

      puts 'Oops, try again:'
    end

    puts ''

    mode1 if mode == 1
    mode2 if mode == 2
  end

  private

  def end_game(player1, player2)
    case @b.detect_winner
    when 'tie'
      puts 'It was a tie! How boring!'
    when player1.symbol
      declare_winner(player1)
    when player2.symbol
      declare_winner(player2)
    else
      puts 'Something went horribly wrong.'
    end
  end

  def declare_winner(player)
    puts "#{player.name} (#{player.symbol}) has won!"
  end

  def mode1
    @p1 = Player.new('Player 1', Board::MARKS[0])
    @p2 = Player.new('Player 2', Board::MARKS[1])

    loop do
      @p1.take_turn(@b)
      break unless @b.detect_winner.nil?

      @p2.take_turn(@b)
      break unless @b.detect_winner.nil?
    end

    @b.print_board
    end_game(@p1, @p2)
  end

  # This could be better
  def mode2
    puts "Would you like to be #{Board::MARKS[0]} or #{Board::MARKS[1]}?"
    puts "(#{Board::MARKS[0]} gets to go first.)"

    while true
      symbol = gets.chomp.upcase
      break if Board::MARKS.include?(symbol)

      puts 'Oops, try again:'
    end

    @p = Player.new('Player', symbol)
    @c = ComputerPlayer.new('Computer', Board::MARKS[0]) if symbol == Board::MARKS[1]
    @c = ComputerPlayer.new('Computer', Board::MARKS[1]) if symbol == Board::MARKS[0]

    loop do
      @p.take_turn(@b) if @p.symbol == Board::MARKS[0]
      @c.take_turn(@b) if @c.symbol == Board::MARKS[0]
      break unless @b.detect_winner.nil?

      @p.take_turn(@b) if @p.symbol == Board::MARKS[1]
      @c.take_turn(@b) if @c.symbol == Board::MARKS[1]
      break unless @b.detect_winner.nil?
    end

    @b.print_board
    end_game(@p, @c)
  end
end
