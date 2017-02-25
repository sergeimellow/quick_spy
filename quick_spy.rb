require 'nokogiri'
require 'restclient'
require 'uri'

def start_scraping(url)
  site_queue = [url]
  host_lists = []
  affected_counter = 0
  request_counter = 0
  while site_queue.any?
    url = site_queue.shift
    puts "Checking #{get_host_without_www(url)}..."
    if !`dig #{get_host_without_www(url)} ns | grep cloudflare`.empty?
      puts "#{get_host_without_www(url)} potentially affected by cloudbleed."
      affected_counter += 1
    end
    begin
      page = Nokogiri::HTML(RestClient::Request.execute(:method => :get, :url => url, :timeout => 10, :open_timeout => 10, :user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36"))
      parse_anchors(page, site_queue, host_lists)
      request_counter += 1
      print_report(site_queue, host_lists, request_counter) if request_counter % 10
    rescue => e
      puts "Exception: #{e}"
    end
  end
end

def parse_anchors(page, site_queue, host_lists)
  page.css('a').each do |link|
    if check_href(link, host_lists)
      site_queue.push(link.attributes['href'].value)
      host_lists << get_host_without_www(link.attributes['href'].value)
    end
  end
end

def check_href(link, host_lists)
  link&.attributes['href']&.value =~ /\A#{URI::regexp(['http', 'https'])}\z/ && !host_lists.include?(get_host_without_www(link.attributes['href'].value))
end

# URL always gets parsed twice
def get_host_without_www(url)
  url = "http://#{url}" if URI.parse(url).scheme.nil?
  host = URI.parse(url).host.downcase
  host.start_with?('www.') ? host[4..-1] : host
end

def print_report(site_queue, host_lists, request_counter)
  puts '---------------- Progress Report Start ----------------'
  puts "#{host_lists.count} unique domains visited."
  puts "#{site_queue.count} sites left in queue."
  puts "#{request_counter} potentially affected sites found."
  puts '----------------  Progress Report End  ----------------'
end

start_scraping('reddit.com')
