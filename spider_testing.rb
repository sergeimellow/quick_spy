require './quick_spy.rb'

# Not sure if this makes sense to be in a module but it makes more sense than
# a class
module SpiderTesting
  def self.find_optimal_thread_count(number_of_tests)
    results = []
    for i in 1..number_of_tests
      results << run_spiders(i + 19)
    end
    print_report(results)
  end

  def self.print_report(results)
    results.each do |result|
      puts '*******'
      puts "Active Threads: #{result[:active_thread_count]}"
      puts "RPM: #{result[:calculated_rpm]}"
      puts '*******'
    end
  end

  # Update spiders to wait until resource is available
  def self.run_spiders(thread_count)
    spider = QuickSpy.new
    spider.use_testing_sites
    thread_count.times do
      spider.create_spider
      sleep 0.25
    end
    sleep 60
    results = spider.return_stats
    spider.destroy_spiders
    return results
  end
end
