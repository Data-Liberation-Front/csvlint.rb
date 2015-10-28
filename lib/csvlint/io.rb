class IO
  def each_in_batches(size = 1000)
    lines = []
    each_line do |line|
      lines << line
      if lines.size >= size
        yield lines
        lines = []
      end
    end
    yield lines
  end
end

class StringIO
  def each_in_batches(size = 1000)
    lines = []
    each_line do |line|
      lines << line
      if lines.size >= size
        yield lines
        lines = []
      end
    end
    yield lines
  end
end
