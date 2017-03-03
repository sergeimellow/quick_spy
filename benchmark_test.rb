require 'thread'
require 'concurrent'
require 'benchmark'


n = 50000000
Benchmark.bm do |x|
  x.report {
    queue = Queue.new
    n.times do |i|
      queue << i
    end
    n.times do |i|
      queue.pop
    end
  }
  x.report {
    array = Concurrent::Array.new
    n.times do |i|
      array << i
    end
    n.times do |i|
      array.pop
    end
  }
end
