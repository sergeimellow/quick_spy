require 'nokogiri'
require 'restclient'
require 'uri'

class QuickSpy
  def initialize
    @site_queue = []
    @hosts_lists = []
    @affected_counter = 0
    @request_counter = 0
  end

  def start_scraping(url)
    @site_queue << url
    while @site_queue.any?
      url = @site_queue.shift
      puts "Checking #{get_host_without_www(url)}..."
      if !`dig #{get_host_without_www(url)} ns | grep cloudflare`.empty?
        puts "#{get_host_without_www(url)} potentially affected by cloudbleed."
        @affected_counter += 1
      end
      begin
        page = Nokogiri::HTML(RestClient::Request.execute(:method => :get, :url => url, :timeout => 10, :open_timeout => 10, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.35"))
        parse_anchors(page)
        @request_counter += 1
        print_report if @request_counter % 10 == 0
      rescue => e
        puts "Exception: #{e}"
      end
    end
  end

  private
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
    puts "#{@request_counter} sites tested."
    puts "#{@site_queue.count} sites left in queue."
    puts "#{@hosts_lists.count} unique domains found."
    puts "#{@affected_counter} potentially affected sites found."
    puts "#{((@affected_counter.to_f / @request_counter) * 100).round(2)}% of sites affected."
    puts '----------------  Progress Report End  ----------------'
    puts ''
  end
end

QuickSpy.new.start_scraping('reddit.com')
