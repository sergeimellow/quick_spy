require 'nokogiri'
require 'restclient'
require 'uri'

class QuickSpy
  def initialize
    @init_time = Time.now
    @site_queue = []
    @hosts_lists = []
    @affected_counter = 0
    @request_counter = 0
    @timeout_counter = 0
    @threads = []
  end

  def report
    loop do
      sleep 10
      print_report
    end
  end

  # Create seperate spider class
  def create_spider
    @threads << Thread.new { start_scraping }
  end

  def destroy_spiders
    @threads.each(&:exit)
  end

  def return_stats
    { init_time: @init_time, affected_counter: @affected_counter,
      request_counter: @request_counter, timeout_counter: @timeout_counter,
      calculated_rpm: calculate_rpm, active_thread_count: active_thread_count,
      dead_thread_count: dead_thread_count }
  end

  # Move this else where.
  def use_testing_sites
    @site_queue = ['www.reddit.com', 'www.namecheap.com',
      'www.nhl.com', 'www.twitter.com', 'www.pinterest.com',
      'www.techcrunch.com', 'www.newegg.com',
      'www.glassdoor.com', 'www.news.ycombinator.com',
      'www.wired.com', 'www.espn.com', 'www.bbc.com',
      'www.nhl.com', 'www.sabres.com', 'www.simediakit.com',
      'www.flickr.com', 'www.gatorzone.com', 'www.instantssl.com',
      'vanityfair.tumblr.com']
  end

  private

  def start_scraping
    while @site_queue.any?
      url = @site_queue.shift
      # puts "Checking #{get_host_without_www(url)}..."
      if !`dig #{get_host_without_www(url)} ns | grep cloudflare`.empty?
        # puts "#{get_host_without_www(url)} potentially affected by cloudbleed."
        @affected_counter += 1
      end
      begin
        page = Nokogiri::HTML(RestClient::Request.execute(:method => :get, :url => url, :timeout => 10, :open_timeout => 10, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.84 Safari/537.35"))
        parse_anchors(page)
        @request_counter += 1
        # print_report if @request_counter % 10 == 0
      rescue => e
        @timeout_counter += 1
        # puts "Exception: #{e}"
      end
    end
    puts '****** Scraper Ended ******'
  end

  def parse_anchors(page)
    page.css('a').each do |link|
      if check_href(link)
        @site_queue.push(link.attributes['href'].value)
        @hosts_lists << get_host_without_www(link.attributes['href'].value)
      end
    end
  end

  def check_href(link)
    link&.attributes['href']&.value =~ /\A#{URI::regexp(['http', 'https'])}\z/ && !@hosts_lists.include?(get_host_without_www(link.attributes['href'].value))
  end

  # URL always gets parsed twice
  def get_host_without_www(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def print_report
    puts ''
    puts '---------------- Progress Report Start ----------------'
    puts "#{calculate_rpm} requests per minute."
    puts "#{Time.now - @init_time} seconds running."
    puts "#{@request_counter} sites tested."
    puts "#{@site_queue.count} sites left in queue."
    puts "#{@hosts_lists.count} unique domains found."
    puts "#{@timeout_counter} timeouts occured."
    puts "#{((@timeout_counter.to_f / @request_counter) * 100).round(2)}% of requests timeout."
    puts "#{@affected_counter} potentially affected sites found."
    puts "#{((@affected_counter.to_f / @request_counter) * 100).round(2)}% of sites affected."
    puts '----------------  Progress Report End  ----------------'
    puts ''
  end

  def calculate_rpm
    elapsed_minutes = (Time.now - @init_time) / 60
    (@request_counter / elapsed_minutes).round
  end

  def active_thread_count
    @threads.count{ |x| x.alive? }
  end

  def dead_thread_count
    @threads.count{ |x| x.stop? }
  end
end

# Results after two minutes of scraping

# 1 Thread
# 16 requests per minute.
# 128.594058 seconds running.

# 2 threads
# 33 requests per minute.
# 120.127803 seconds running.

# 3 threads
# 64 requests per minute.
# 120.082089 seconds running.

# 4 threads
# 88 requests per minute.
# 110.064693 seconds running.

# 5 threads
# 107 requests per minute.k
# 120.539096 seconds running.

# 6 threads
# 136 requests per minute.
# 120.348035 seconds running.

# 7 threads
# 147 requests per minute.
# 120.427262 seconds running.

# 8 threads
# 177 requests per minute.
# 110.585258 seconds running.

# 9 threads
# 211 requests per minute.
# 122.097392 seconds running

# 10 threads
# 241 requests per minute.
# 122.341673 seconds running.

# Why am I manually testing these??
# ~20ish threads seems to be the sweet spot. Any more doesn't really yield too much
