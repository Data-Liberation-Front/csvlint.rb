class IO
  def each_in_batches(size = 1000)
    lines = []
    index = 0
    each_line do |line|
      lines << line
      if lines.size >= size
        yield lines, index
        index += 1
        lines = []
      end
    end
    yield lines, index
  end
end

class StringIO
  def each_in_batches(size = 1000)
    lines = []
    index = 0
    each_line do |line|
      lines << line
      if lines.size >= size
        yield lines, index
        index += 1
        lines = []
      end
    end
    yield lines, index
  end
end
