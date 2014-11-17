class Board
  attr_reader :size, :grid

  def initialize (size = 9, number_bombs = 10)
    @grid = create_grid(size)
    @size = size
    @number_bombs = number_bombs

    add_bombs_to_grid
  end

  def create_grid(size)
    empty_grid = Array.new(size){ Array.new (size) }
    empty_grid.map.with_index do |row, row_i|
      row.map.with_index do |col, col_i|
        Tile.new(self, [row_i, col_i])
      end
    end

  end

  def [] (pos)
    @grid[pos[0]][pos[1]]
  end

  def inspect
  end

  private
  def add_bombs_to_grid
    placed_bombs = 0
    raise "Too many bombs!" if @number_bombs > (@size ** 2)
    until placed_bombs == @number_bombs
      random_tile = self[[rand(9), rand(9)]]
      unless random_tile.bombed?
        random_tile.bombed = true
        placed_bombs += 1
      end
    end

    nil
  end


end

class Tile

  INCREMENTS = [0,1,-1,1,-1].permutation(2).to_a.uniq

  attr_reader :position
  attr_writer :bombed, :flagged, :revealed

  def initialize (board, position)
    @board = board
    @position = position
    @bombed = false
    @flagged = false
    @revealed = false
  end

  def neighbors
    neighbors = []
    INCREMENTS.each do |increment|
      row = position[0] + increment[0]
      col = position[1] + increment[1]
      new_position = [row, col]
      if row.between?(0, @board.size - 1) &&
        col.between?(0, @board.size - 1)
        neighbors << @board[new_position]
      end
    end

    neighbors
  end

  def neighbor_bomb_count
    neighbors.reduce(0) do |count, neighbor|
      count + (neighbor.bombed? ? 1 : 0)
    end
  end

  def reveal
    return if self.revealed?
    @revealed = true
    return if self.bombed?
    if neighbor_bomb_count == 0
      neighbors.each(&:reveal)
    end
    nil
  end

  def flag
    @flagged = true

    nil
  end

  def bombed?
    @bombed
  end

  def flagged?
    @flagged
  end

  def revealed?
    @revealed
  end

  def to_s
    if bombed? && revealed?
      "☠ "
    elsif flagged?
      "⚑ "
    elsif revealed?
      bomb_count = neighbor_bomb_count
      "#{bomb_count.zero? ? "□" : bomb_count} "
    else
      "■ "
    end
  end

  def inspect
  end


end
