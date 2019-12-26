class TicTacToe
    # board is arranged as
    # 0 1 2
    # 3 4 5
    # 6 7 8

    WINNING_SEQUENCES =  [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], # horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], # vertical
        [0, 4, 8], [2, 4, 6] # diagonal
    ]

    def initialize(board = nil, players = nil)
        board = Array.new(9) if board.nil?
        players = [:X, :O] if players.nil?

        @board = board
        @players = players
    end

    def turn
        return @players[0]
    end

    def make_move(i)
        raise ArgumentError, 'Invalid move' unless @board[i].nil?
        
        # copy the board & make move
        new_board = @board.map(&:dup)
        new_board[i] = turn

        TicTacToe.new(new_board, @players.rotate)
    end

    def full?
        !@board.include?(nil)
    end

    def winner
        WINNING_SEQUENCES.each do |seq|
            @players.each do |player|
                return player if seq.all? { |i| @board[i] == player }
            end
        end
        nil
    end

    def over?
        if not winner.nil?
            return true
        else
            return full?
        end
    end

    def available_positions
        @board.map.with_index
                  .select { |e, i| e.nil? }
                  .map { |e, i| i }
    end

    def to_s
        @board.map{ |e| " #{e ? e : ' '} " }
              .each_slice(3)
              .map { |row| row.join("|") }
              .join("\n---+---+---\n")
    end
end

class AI
    attr_reader :player
    def initialize(player = :X)
        @player = player
        @min_score = Hash.new
        @max_score = Hash.new
    end


    def next_move(game)
        game.available_positions
                .map{ |i| [i, min_value(game.make_move(i))] }
                .max_by{ |i, value| value }[0]
    end

    private
    def score(game)
        # assuming game has ended
        if game.winner.nil?
            0
        elsif game.winner == @player
            1
        else
            -1
        end  
    end
    
    def min_value(game)
        if @min_score.key?(game.to_s)
            @min_score[game.to_s]
        elsif game.over?
            score(game)
        else
            @min_score[game.to_s] = game.available_positions
                                        .map{ |i| [i, max_value(game.make_move(i))] }
                                        .min_by{ |i, value| value }[1]
            @min_score[game.to_s]
        end
    end

    def max_value(game)
        if @max_score.key?(game.to_s)
            @max_score[game.to_s]

        elsif game.over?
            score(game)
        else
            @max_score[game.to_s] = game.available_positions
                                        .map{ |i| [i, min_value(game.make_move(i))] }
                                        .max_by{ |i, value| value }[1]
            @max_score[game.to_s]
        end
    end

end

class User 
    def initialize(player = :O)
        @player = player
    end

    def next_move(game)
        puts (0..8).map{ |e| " #{e ? e : ' '} " }.each_slice(3).map { |row| row.join("|") }.join("\n---+---+---\n")
        print "enter your move: "
        move = STDIN.gets.to_i
        if game.available_positions.include?(move)
            move 
        else
            puts "invalid move. try again."
            next_move(game)
        end
    end
end

user = ARGV[0]
if user == 'X'
    puts 'X: you, O: ai'
    players = { :X => User.new(:X), :O => AI.new(:O) }
elsif user == 'O'
    puts 'X: ai, O: you'
    players = { :O => User.new(:O), :X => AI.new(:X) }
else
    puts "invalid symbol"
    exit
end

game = TicTacToe.new

while not game.over?
    puts "#{game.turn}'s turn\n"
    
    player = players[game.turn]
    move = player.next_move(game)
    game = game.make_move(move)
    
    puts "#{game}\n\n"
end

puts "#{game.winner ? game.winner.to_s + ' wins' : 'draw'}"