require './quick_spy.rb'

# Not sure if this makes sense to be in a module but it makes more sense than
# a class
module SpiderTesting
  def find_optimal_thread_count
    spider = QuickSpy.new
  end
end
