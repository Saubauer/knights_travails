class Board
  attr_accessor :grid, :matrix

  def initialize(y, x)
    @y = y
    @x = x
    @grid = []
    @turn = -1
    @queue = []
    @matrix = []
    make_board(y, x)
  end

  def knight_moves(start, finish)
    return reset if start == finish
    return reset if start.any? { |n| n >= @y || n >= @x || n < 0 }
    return reset if finish.any? { |n| n >= @y || n >= @x || n < 0 }

    find_node(finish).trail = 'G'
    node = find_node(start)
    node.has_knight = true
    @queue = calculate(node, finish)

    until node.coords == finish
      target = @queue.shift.coords
      node = find_node(move(node, target))
      node.has_knight = true
      draw_board
    end
    reset
  end

  private

  def reset
    @grid = []
    @turn = -1
    make_board(@y, @x)
  end

  def make_board(y, x)
    return puts "input can't be lower than 4" if y <= 3 || x <= 3

    temp = []
    countX = 0
    countY = 0
    id = 0
    while countY < y
      while countX < x && countY < y
        temp << Cell.new(countY, countX, id)
        id += 1
        countX += 1
      end
      @grid << temp
      temp = []
      countY += 1
      countX = 0
    end
    map_jump
    @matrix = make_matrix
  end

  def map_jump
    @grid.each do |row|
      row.each do |cell|
        y = cell.coords.first
        x = cell.coords.last
        possible = [[y + 2, x + 1], [y + 2, x - 1], [y + 1, x + 2], [y - 1, x + 2], [y - 2, x + 1], [y - 2, x - 1],
                    [y + 1, x - 2], [y - 1, x - 2]]
        cell.possible_jumps = possible.filter do |coord|
          coord if coord.all? { |test| test >= 0 && test < @y && test < @x }
        end
      end
    end
  end

  def make_matrix
    matrix = []
    @grid.each do |row|
      row.each do |cell|
        temp = []
        (@y * @x).times do |i|
          temp << if cell.possible_jumps.include?(find_node_id(i).coords)
                    1
                  else
                    0
                  end
        end
        matrix << temp
      end
    end
    matrix
  end

  def move(root, target)
    root.has_knight = false
    root.trail = @turn
    @turn += 1
    target
  end

  def calculate(root, target)
    search = BreadthFirstSearch.new(@matrix, root, @grid)
    search.shortest_path_to(find_node(target))
  end

  def draw_board
    cls
    @grid.each do |row|
      puts ' '
      row.each do |cell|
        print "#{if cell.has_knight
                   'X'
                 else
                   (cell.trail || '.').to_s
                 end} "
      end
    end
    puts ''
    sleep(0.3)
  end

  def find_node(coords)
    return coords if coords.instance_of?(Cell)
    return if coords.any? { |test| test < 0 || test >= @y || test >= @x }

    @grid.each do |row|
      row.each do |cell|
        return cell if cell.coords == coords
      end
    end
  end

  def find_node_id(id)
    return id if id.instance_of?(Cell)
    return if id > @y * @x || id < 0

    @grid.each do |row|
      row.each do |cell|
        return cell if cell.id == id
      end
    end
  end

  def cls
    system('cls') || system('clear')
  end
end

class Cell
  attr_accessor :has_knight, :possible_jumps, :trail
  attr_reader :coords, :id

  def initialize(y, x, id)
    @coords = [y, x]
    @id = id
    @has_knight = false
    @possible_jumps = []
    @trail = nil
  end
end

class BreadthFirstSearch
  def initialize(matrix, source_node, grid)
    @grid = grid
    @matrix = matrix
    @node = source_node
    @visited = []
    @edge_to = {}

    bfs(source_node)
  end

  def shortest_path_to(node)
    return unless has_path_to?(node)

    path = []

    while node != @node
      path.unshift(node)
      node = @edge_to[node]
    end

    path.unshift(@node)
  end

  private

  def bfs(node)
    queue = []
    queue << node
    @visited << node

    while queue.any?
      current_node = queue.shift
      queue
      current_node.possible_jumps.each do |node|
        node = find_node(node)
        next if @visited.include?(node)

        queue << node
        @visited << node
        @edge_to[node] = current_node
      end
    end
  end

  def has_path_to?(node)
    @visited.include?(node)
  end

  def find_node(coords)
    @grid.each do |row|
      row.each do |cell|
        return cell if cell.coords == coords
      end
    end
  end
end
