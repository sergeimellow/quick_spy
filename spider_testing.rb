require './quick_spy.rb'

# Not sure if this makes sense to be in a module but it makes more sense than
# a class
module SpiderTesting
  def self.find_optimal_thread_count(number_of_tests)
    results = []
    for i in 1..number_of_tests
      results << run_spiders(i)
    end
    return results
  end

  # Update spiders to wait until resource is available
  def self.run_spiders(thread_count)
    spider = QuickSpy.new
    spider.use_testing_sites
    thread_count.times do
      spider.create_spider
      sleep 0.25
    end
    sleep 120
    results = spider.return_stats
    spider.destroy_spiders
    return results
  end
end
